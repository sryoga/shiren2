class RankingController < ApplicationController

    require 'net/https'
    require 'net/https'
    require 'uri'
    ######################################################メソッド########################################################

    #URLからダンジョンの名前を取得
    def getDungeonName(dungeonURLStr)

        Constants::DUNGEON_LINK.each_with_index{|value, index|
            if dungeonURLStr == value
                return Constants::DUNGEON_NAME[index]
            end
        }
        return ""
    end

    def getDungeonColor(dungeonURLStr)
        Constants::DUNGEON_LINK.each_with_index{|value, index|
            if dungeonURLStr == value
                return Constants::DUNGEON_COLOR[index]
            end
        }
        return ""
    end

    ######################################################メソッド終わり######################################################

    PER = 10

    #URLからダンジョンと日付を取得してデータベースから記録も取得
    def dungeon
        #URLからダンジョンを取得
        @dungeonurl = params[:dungeon]
        @dungeonname = getDungeonName(@dungeonurl)
        #不正なURLを入れられたときにTopに戻る処理
        if @dungeonname == ""
            redirect_to "/"
            return
        end

        #選択されたダンジョンの記録のみを抽出
        @ranks = Rank.RankDungeonChoose(@dungeonname)
        #アーカイブを取得(各日付と記録数を取得)
        @archives = @ranks.GetArchive
        if params[:yyyymm] != nil
            if(params[:yyyymm]=~ /^[0-9]+$/)
                @yyyymm = params[:yyyymm]
                year = @yyyymm[0,4].to_i
                month = @yyyymm[4,2].to_i
                season, @ranks = @ranks.GetSeasonRecord(year,month)
                @datetitle = "#{year}年#{season}"
            else
                #数値以外が入れられているとき
                redirect_to "/"
                return
            end
        #日付が選択されていないURLが入れられているとき
        else
            @datetitle = " 歴代"
        end
        @color = getDungeonColor(@dungeonurl)
        @movieonly = false
        @useronly = false
        @bestonly = false
        # フィルターをかけた時の動作
        if request.post?
            params[:filt].each do | kind,onoff |
                if kind.to_s == "movie_only" && onoff.to_i == 1
                    @ranks = @ranks.RankMovieOnly
                    @movieonly = true
                end
                if kind.to_s == "user_only" && onoff.to_i == 1
                    @ranks = @ranks.RankUserOnly
                    @useronly = true
                end
                if kind.to_s == "best_only" && onoff.to_i == 1
                    # @ranks = @ranks.RankBestOnly
                    @bestonly = true
                end
            end
        # もっと見るを押した時の動作
        elsif request.xhr?
            puts params[:movieonly]
            puts params[:useronly]
            puts params[:bestonly]
            if params[:movieonly] == "true"
                @ranks = @ranks.RankMovieOnly
                @movieonly = true
            end
            if params[:useronly] == "true"
                @ranks = @ranks.RankUserOnly
                @useronly = true
            end
            if params[:bestonly] == "true"
                # @ranks = @ranks.RankBestOnly
                @bestonly = true
            end
        # 普通のGetをした時の動作
        else
            @ranks = @ranks.RankMovieOnly
            @movieonly = true
        end
        @ranks = @ranks.order(:result).page(params[:page]).per(PER)
        render 'ranking'
    end

    #申請を押したときに新しいデータを作成
    def newrecord
        @rank = Rank.new
        #ログインしている場合は初期値を入れる
        if user_signed_in?
            @rank.name = current_user.name
            @rank.user_id = current_user.id
        end
    end

    #確認画面へ行くときのデータ運びとバリデーション
    def recordconfirm
        @rank = Rank.new(rank_params)
        @rank[:result]= params["hour"].to_i * 3600 + params["minute"].to_i * 60 + params["second"].to_i
        render :newrecord if @rank.invalid?
    end

    #申請後確認画面でOKを押したとき
    def create
        @rank = Rank.new(rank_params)
        if user_signed_in?
            @rank.user_id = current_user.id
        end
        if params[:cache][:recordimage] != nil
            @rank.recordimage.retrieve_from_cache! params[:cache][:recordimage]
        end
        if params[:back]
            render 'newrecord'
        elsif @rank.save! then
            @rank.SendDiscordWebHook(@rank,ENV['DISCORD_WEBHOOK'],"新たな申請が来ました！")
            redirect_to "/"
        else
            render 'newrecord'
        end
    end

    def description

    end

    private

    ############################################################Strong Parameter############################################################
    def rank_params
        params.require(:rank).permit(:name,:dungeon,:result,:movie,:resultdate,:recordimage,:beforeseason,:remark)
    end
end

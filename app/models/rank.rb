class Rank < ApplicationRecord
    belongs_to :user, optional: true
    #カラムの名前をmount_uploaderに指定
    mount_uploader :recordimage, RecordimageUploader
    #名前が入力されていること
    validates :name, presence: true, length: {maximum: 15}
    validates :result, presence: true
    validates :dungeon, presence: true
    validates :movie_or_image, presence: true
    validate :both_true_vali
    validate :no_reject_message
    validate :movie_valid

    after_save :permit_change

    def movie_valid
        if movie != "" && movie != nil
            unless movie.start_with?("https://","http://")
                errors.add(:movie, "を指定してください")
            end
        end
    end

    def permit_change
        if self.permission == true
            #TweetNewRecord
            SendDiscordWebHook(self,ENV['DISCORD_WEBHOOK_ALL'],"ランキングが更新されました！！")
        end
    end

    def TweetNewRecord
        topurl = "https://shiren2.herokuapp.com"
        twitter = Twitter::REST::Client.new do |config|
            config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
            config.consumer_secret     = ENV['TWITTER_CONSUMER_KEY_SECRET']
            config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
            config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
        end
        time = ""
        if self.result >= 3600 then
            time = (self.result.div(3600).to_s + "時間" + ((self.result.modulo(3600)).div(60)).to_s + "分" + ((self.result.modulo(3600)).modulo(60)).to_s + "秒")
        else
            time = ((self.result.div(60)).to_s + "分" + (self.result.modulo(60)).to_s + "秒")
        end
        sendmessage = "【記録申請通知】\n#{self.dungeon}のランキングが更新されました。\nおめでとうございます！！\nプレイヤー：#{User.find(self.user_id).name}\n記録：#{time}\n詳しくはこちらから→ #{topurl}"
        #twitter.update(sendmessage)
        puts(sendmessage)
    end

    def SendDiscordWebHook(rank,webhook,message)
        #PostまたはGet先のURL
        uri = URI(webhook)
        #Net::HTTPのインスタンスを生成
        https = Net::HTTP.new(uri.host, uri.port)
        #ssl(https)を利用する場合はtrueに
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        req = Net::HTTP::Post.new(uri.path)

        #リクエストヘッダ
        req['Content-Type'] = 'application/json'

        #送りたいデータを格納
        topurl = "https://shiren2.herokuapp.com"
        botname = "記録通知くん"
        boticon = ENV['DISCORD_DEFAULTICON']
        usericon = ENV['DISCORD_DEFAULTICON']
        if rank.result >= 3600 then
            time = rank.result.div(3600).to_s + "時間" + ((rank.result.modulo(3600)).div(60)).to_s + "分" + ((rank.result.modulo(3600)).modulo(60)).to_s + "秒"
        else
            time =(rank.result.div(60)).to_s + "分" + (rank.result.modulo(60)).to_s + "秒"
        end
        if rank.user_id != nil
            user = User.find(rank.user_id)
            if user.icon.url != nil && user.icon.url != ""
                usericon = user.icon.url
            end
        end
        auther = {"name": rank.name}
        if rank.user_id != nil
            auther["url"] = "#{topurl}"
        end
        auther["icon_url"] = boticon

        sendjson = {
            'username': botname,
            "avatar_url": usericon,
            'content': message,
            "embeds": [
            {
                "color": 5620992,
                "author": auther,
                "fields": [
                    {
                        "name": "ダンジョン",
                        "value": rank.dungeon,
                    },
                    {
                        "name": "記録",
                        "value": time,
                    }
                ]
            }]
            }
        req.body = sendjson.to_json

        #レスポンスデータの受け取り
        result = https.request(req)
    end

    def no_reject_message
        if rejection == true && ( rejectioncomment == "" || rejectioncomment == nil )
            errors.add(:rejectioncomment, "コメントがありません")
        end
    end

    # permissionとrejectionが両方Trueの時にエラーとする
    def both_true_vali
        if permission == true && rejection == true
            errors.add(:permission, "rejectionがTrueです")
            errors.add(:rejection, "permissionがTrueです")
        end
    end

    #アーカイブのデータを取得する
    def self.GetArchive
        self.group("DATE_FORMAT(created_at, '%Y%m')").order("DATE_FORMAT(created_at, '%Y%m') desc").count
    end

    def self.GetSeasonRecord(year,month)
        season = ""
        rank = self
        if(month == 1 || month == 2|| month == 3)
            season = "冬期"
            rank = self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}01' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}02' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}03' and beforeseason = FALSE)").or(self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}04' and beforeseason = TRUE)"))
        elsif(month == 4 || month == 5 || month == 6)
            season = "春期"
            rank = self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}04' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}05' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}06' and beforeseason = FALSE)").or(self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}07' and beforeseason = TRUE)"))
        elsif(month == 7 || month == 8|| month == 9)
            season = "夏期"
            rank = self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}07' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}08' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}09' and beforeseason = FALSE)").or(self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}10' and beforeseason = TRUE)"))
        elsif(month == 10 || month == 11 || month == 12)
            season = "秋期"
            rank = self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}10' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}11' or DATE_FORMAT(created_at, '%Y%m') = '#{year.to_s}12' and beforeseason = FALSE)").or(self.where("(DATE_FORMAT(created_at, '%Y%m') = '#{(year + 1).to_s}01' and beforeseason = TRUE)"))
        end
        return season,rank
    end

    #データベースからダンジョンに応じたデータを取得
    def self.RankDungeonChoose(dungname)
        return self.where(dungeon: dungname).where(permission: true)
    end

    # 動画が付いているランキングを取得
    def self.RankMovieOnly
        ranks = self.where.not(movie: nil)
        return ranks.where.not(movie: "")
    end

    # ユーザーのみのランキングを取得
    def self.RankUserOnly
        return self.where.not(user_id: nil)
    end

    private
        def movie_or_image
            recordimage.presence or movie.presence
        end
end

class UserController < ApplicationController

    PER = 10

    def profile
        @uid = params[:id]
        @user = User.find_by_id(@uid)
        if @user.nil?
            redirect_to "/"
            return
        end
        @dungeons = Dungeon.all
        # 許可済みの記録
        @allranks = @user.ranks
        @ranks = @allranks.where(permission: true)
        @ranks = @ranks.order(:result)
        @myranks = []
        @dungeons.each do |dungeon|
            @myranks.push(@ranks.RankDungeonChoose(dungeon.id).page(params[:page]).per(PER))
        end

        # 許可前の記録
        @nopermitranks = @allranks.where(permission: false).where(rejection: false)

        # 拒否された記録
        @rejectioncount = 0
        @rejectranks = @user.ranks.where(rejection: true)
        @rejectranks.each do |rank|
            puts Time.now - rank.created_at
            if Time.now - rank.created_at < 604800
                @rejectioncount = @rejectioncount + 1
            end
        end


        # これ以下はAjax通信の場合のみ通過
        return unless request.xhr?

        case params[:type]
        when 'saihate', 'well','onigashima','story','shrine'
            render "user/#{params[:type]}"
        end
    end

    def edit
        @uid = params[:id]
        if current_user.id != @uid.to_i
            redirect_to "/"
            return
        end
        @user = User.find_by_id(@uid)
    end

    def update
        @user = User.find_by_id(params[:id])
        if @user.name != params[:name]
            @user.name = params[:name]
        end
        if @user.niconico != params[:niconico]
            @user.niconico = params[:niconico]
        end
        if @user.youtube != params[:youtube]
            @user.youtube = params[:youtube]
        end
        if @user.twitch != params[:twitch]
            @user.twitch = params[:twitch]
        end
        if @user.introduction != params[:text]
            @user.introduction = params[:text]
        end
        if params[:icon] != nil
            @user.icon = params[:icon]
        end
        if @user.save
            redirect_to "/user/#{params[:id]}"
        else
            @user.name = User.find_by_id(params[:id]).name
            render :edit
        end
    end

    def update_password
        @uid = params[:id]
        if current_user.id != @uid.to_i
            redirect_to "/"
            return
        end
        @user = User.find_by_id(@uid)
        user_params = [password: params[:new_password],password_confirmation: params[:new_password_confirmation],current_password: params[:old_password]]
        result = current_user.update_with_password(user_params[0])

        if result
            # パスワードを変更するとログアウトしてしまうので、再ログインが必要
            redirect_to "/users/sign_in", notice: "パスワードを変更しました。再度ログインしてください。"
        else
            @error = "パスワードが間違っています。"
            render :edit
        end
    end

end

# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy]

    # GET /users
    # GET /users.json
    def index
      @users = User.all
    end

    # GET /users/1
    # GET /users/1.json
    def show; end

    # GET /users/new
    def new
      @user = User.new
    end

    # GET /users/1/edit
    def edit; end

    def playlists
      @playlist = spotify_user.playlists
    end

    def recently_played_tracks
      currently_playing = nil
      begin
        currently_playing = RSpotify::Player.new(User.first.rspotify_user).currently_playing
      rescue StandardError
        # ignored
      end
      tracks = auth_user.rspotify_user.recently_played(limit: 10)
      tracks.unshift currently_playing if currently_playing

      render json: tracks.uniq(&:id)
    end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def create_push_notif_preference
      params.permit!
      pref = PushNotifPreference.new user_id: auth_user.id
      pref.preference = params[:preference].to_hash
      pref.save!
      render json: :ok, status: :created
    end

    def devices
      render json: auth_user.rspotify_user.devices
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :spotify_id)
    end
  end
end

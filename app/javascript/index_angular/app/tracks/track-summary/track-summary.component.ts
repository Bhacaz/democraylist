import {Component, Input, OnChanges, OnDestroy, OnInit, SimpleChanges} from '@angular/core';
import {DemocraylistService} from '../../democraylist/democraylist.service';
import {PlaylistChangeService} from '../../democraylist/playlist-change.service';
import {AudioService} from '../audio-player.service';
import {MenuItem} from 'primeng/api';
import {ActivatedRoute, Router} from '@angular/router';
import templateString from './track-summary.component.html'
import stylesString from './track-summary.component.scss'

@Component({
  selector: 'app-track-summary',
  template: templateString,
  styles: [stylesString],
})
export class TrackSummaryComponent implements OnInit, OnDestroy, OnChanges {

  @Input() track;
  @Input() playlist;
  trackIdsInPlaylist = [];
  showPlayButton: boolean = false;
  currentlyPlaying: boolean = false;
  audioPlayerSubscription;
  menuItems: MenuItem[];
  showInfo: boolean = false;
  trackId: number;
  userLocalStorage;
  focus;
  showVotebutton;
  releaseDate;

  constructor(
    private democraylistService: DemocraylistService,
    private voteService: PlaylistChangeService,
    private audioService: AudioService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.route.queryParams
      .subscribe(params => {
        const trackId = params.track_id;
        if (trackId) {
          this.trackId = parseInt(trackId);
        }
      });
    this.userLocalStorage = JSON.parse(localStorage.getItem('user'));
  }

  ngOnInit() {
    this.currentlyPlaying = this.audioService.currentlyPlayingTrackId === this.track.id;
    this.showPlayButton = this.currentlyPlaying;

    this.audioPlayerSubscription = this.audioService.audioPlayerEvent().subscribe(trackId => {
      this.currentlyPlaying = trackId === this.track.id;
      this.showPlayButton = this.currentlyPlaying;
    });
    this.menuItems = [
      {label: 'Open on spotify', icon: 'fa-brands fa-spotify', command: this.openWithSpotify},
      {label: 'Show info', icon: 'fa-solid fa-info-circle', command: this.toggleShowInfo}
    ];
    if (this.playlist && this.playlist.user_id === this.userLocalStorage.id) {
      this.menuItems.push({label: 'Remove', icon: 'fa-solid fa-minus-circle', command: this.removeTrack});
    }
    this.setAddButtonDisabled();
    this.focus = this.track.id === this.trackId;
    this.showVotebutton = this.playlist.user_id === this.userLocalStorage.id ||
      this.playlist.subscribed;
    this.track.artistNames = this.track.artists.map(artist => artist.name).join(', ');
    if (!this.track.playlist_id) { this.initReleaseDate(); }
  }

  ngOnDestroy() {
    // unsubscribe to ensure no memory leaks
    this.audioPlayerSubscription.unsubscribe();
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes.playlist) {
      this.playlist = changes.playlist.currentValue;
      this.setAddButtonDisabled();
    }
  }

  upVote() {
    this.democraylistService.upVotePatch(this.track.id)
      .subscribe(data => {
        if (this.track.my_vote) {
          this.track.vote_count += 2;
        } else {
          this.track.vote_count += 1;
        }
        this.track.my_vote = 'up';
        this.voteService.voteChanged(this.track.playlist_id);
      });
  }

  downVote() {
    this.democraylistService.downVotePatch(this.track.id)
      .subscribe(data => {
        if (this.track.my_vote) {
          this.track.vote_count -= 1;
        }
        this.track.my_vote = 'down';
        this.voteService.voteChanged(this.track.playlist_id);
      });
  }

  mouseEnterPlayButton() {
    if (this.track.preview_url && !this.currentlyPlaying) {
      this.showPlayButton = true;
    }
  }

  mouseLeavePlayButton() {
    if (!this.currentlyPlaying) {
      this.showPlayButton = false;
    }
  }

  playPreview() {
    this.audioService.play(this.track.id, this.track.preview_url);
  }

  trackChangeTrigger() {
    this.democraylistService.addTrackToPlaylist(this.playlist.id, this.track.id).subscribe(data => {
      this.router.navigate(['playlists', this.playlist.id]);
    });
  }

  removeTrack = (event) => {
    this.democraylistService.removeTrackToPlaylist(this.track.id)
      .subscribe(res => this.voteService.voteChanged(this.playlist.id));
  }

  openWithSpotify = (event) => {
    window.open(this.track.uri, '_blank');
  }

  toggleShowInfo = (event) =>  {
    this.showInfo = true;
  }

  initReleaseDate() {
    const date = new Date(this.track.album.release_date);

    this.releaseDate =
      date.toLocaleString('fr-CA', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  }

  setAddButtonDisabled() {
    if (this.playlist) {
      this.playlist.tracks.map(track => this.trackIdsInPlaylist.push(track.spotify_id));
      this.playlist.tracks_submission.map(track => this.trackIdsInPlaylist.push(track.spotify_id));
      this.playlist.tracks_archived.map(track => this.trackIdsInPlaylist.push(track.spotify_id));
      this.track.disableAddButton = this.trackIdsInPlaylist.indexOf(this.track.id) > -1;
    }
  }
}

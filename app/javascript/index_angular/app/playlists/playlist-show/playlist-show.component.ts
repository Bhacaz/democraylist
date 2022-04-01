import {Component, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';
import {DemocraylistService} from '../../democraylist/democraylist.service';
import {PlaylistChangeService} from '../../democraylist/playlist-change.service';
import {MenuItem, MessageService} from 'primeng/api';
import {copyToClipboard} from '../../common/copy-to-clipboard';
import {BottomSheetComponent} from '../../common/bottom-sheet/bottom-sheet.component';
import templateString from './playlist-show.component.html'
import stylesString from './playlist-show.component.scss'

declare var navigator;

@Component({
  selector: 'app-playlist-show',
  template: templateString,
  styles: [stylesString],
  providers: [MessageService]
})
export class PlaylistShowComponent implements OnInit, OnDestroy {

  playlistId: number;
  playlist: any;
  voteChangingSubscription;
  innerWidth: number;
  playMenuItem: MenuItem[];
  menuItems: MenuItem[];
  playOnTitle: string;
  owner;
  @ViewChild('sheetComponent') sheetComponentView: BottomSheetComponent;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private democraylistService: DemocraylistService,
    private voteService: PlaylistChangeService,
    private messageService: MessageService
  ) {
    this.route.params.subscribe(params => {
      this.playlistId = +params.id;
      this.getPlaylist();
    });

    this.voteChangingSubscription = this.voteService.voteChanging().subscribe(playlistId => this.getPlaylist());

    this.playMenuItem = [
      {label: 'Loading...', icon: 'fa-solid fa-spinner'}];
  }

  ngOnInit(): void {
    this.innerWidth = window.innerWidth;
  }

  ngOnDestroy() {
    // unsubscribe to ensure no memory leaks
    this.voteChangingSubscription.unsubscribe();
  }

  getPlaylist() {
    this.democraylistService.getPlaylist(this.playlistId)
      .subscribe(data =>  {
        this.playlist = data
        this.owner = this.playlist.user_id === JSON.parse(localStorage.getItem('user')).id;
      });
  }

  playTracks = (event) => {
    this.democraylistService.playQueue(this.playlistId, 'tracks').subscribe();
  }

  playSubmissions = (event) => {
    this.democraylistService.playQueue(this.playlistId, 'submissions').subscribe();
  }

  playUnvoted = (event) => {
    this.democraylistService.playQueue(this.playlistId, 'unvoted').subscribe();
  }

  playUpVoted = (event) => {
    this.democraylistService.playQueue(this.playlistId, 'upvoted').subscribe();
  }

  playDownVoted = (event) => {
    this.democraylistService.playQueue(this.playlistId, 'downvoted').subscribe();
  }

  showMenu(menu) {
    this.menuItems = [
      {label: 'Open on spotify', icon: 'fa-brands fa-spotify', command: this.openWithSpotify},
      {label: 'Statistic', icon: 'fa-solid fa-bar-chart', command: this.openStats}
    ];

    if (this.owner) {
      this.menuItems.push({label: 'Edit', icon: 'fa-solid fa-pencil', command: this.redirectToEdit});
    }

    if (this.owner || this.playlist.subscribed) {
      this.menuItems.push({label: 'Share playlist', icon: 'fa-solid fa-share-alt', command: this.copyShareLink});
    }
    menu.toggle();
  }

  copyShareLink = (event) => {
    this.democraylistService.getPlaylistShareLink(this.playlist.id).subscribe(data => {
      const shareLink = '/p/' + data.hash;
      if (navigator.share) {
        navigator.share({
          title: 'Democraylist',
          text: 'Contribute to my playlist on Democraylist. ' + this.playlist.name,
          url: shareLink,
        });
      } else {
        copyToClipboard(shareLink);
        this.sheetComponentView.close();
        this.messageService.add({severity: 'success', summary: 'Link copied to clipboard'});
      }
    });
  }

  unsubscribed() {
    this.democraylistService.unsubscripbedToPlaylist(this.playlist.id)
      .subscribe(data => {
        this.playlist.subscribed = false;
        this.router.navigate(['/']);
      });
  }

  subscribed() {
    this.democraylistService.subscripbedToPlaylist(this.playlist.id)
      .subscribe(data => {
        this.playlist.subscribed = true;
        this.router.navigate(['/playlists', this.playlist.id]);
      });
  }

  openWithSpotify = (event) => {
    window.open(this.playlist.uri, '_blank');
  }

  openStats = (event) => {
    this.router.navigate(['/playlists', this.playlist.id, 'stats']);
  }

  redirectToEdit = (evnet) => {
    this.router.navigate(['/playlists', this.playlist.id, 'edit']);
  }

  redirectToAddTrack() {
    this.router.navigate(['playlists', this.playlistId, 'add-track']);
  }

  playButtonClicked(menu: any) {
    menu.toggle();

    let noDevice = true;
    this.playOnTitle = 'No active device';
    this.democraylistService.getUserPlayerDevices()
      .subscribe(
      data => {
        if (data.length > 0) {
          noDevice = false;
          this.playOnTitle = 'Play on ' + data[0].name;
        }

        this.playMenuItem = [
          {label: 'Tracks', icon: 'fa-solid fa-music', command: this.playTracks, disabled: noDevice},
          {label: 'Submission', icon: 'fa-solid fa-headphones', command: this.playSubmissions, disabled: noDevice},
          {label: 'Unvoted', icon: 'fa-solid fa-question-circle', command: this.playUnvoted, disabled: noDevice},
          {label: 'Up voted', icon: 'fa-solid fa-arrow-up', command: this.playUpVoted, disabled: noDevice},
          {label: 'Down voted', icon: 'fa-solid fa-arrow-down', command: this.playDownVoted, disabled: noDevice}
        ];
      }
    );
  }
}

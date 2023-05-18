import {Component, Input, OnInit} from '@angular/core';
import {Router} from '@angular/router';
import {DemocraylistService} from '../../democraylist/democraylist.service';
import {MenuItem} from 'primeng/api';
import templateString from './playlist-summary.component.html'
import stylesString from './playlist-summary.component.scss'

@Component({
  selector: 'app-playlist-summary',
  template: templateString,
  styles: [stylesString],
})
export class PlaylistSummaryComponent implements OnInit {

  @Input() playlist;
  menuItems: MenuItem[];

  constructor(
    private router: Router,
    private democraylistService: DemocraylistService
  ) { }

  ngOnInit(): void {
    this.menuItems = [
      {label: 'Open on spotify', icon: 'fa-brands fa-spotify', command: this.openWithSpotify},
      {label: 'Statistic', icon: 'fa-solid fa-bar-chart', command: this.openStats}
    ];

    if (!this.myPlaylist()) {
      if (this.playlist.subscribed) {
        this.menuItems.push({label: 'Unsubscribed', icon: 'fa-solid fa-heart', command: this.unsubscribed});
      } else {
        this.menuItems.push({label: 'Subscribed', icon: 'fa-regular fa-heart', command: this.subscribed});
      }
    }
  }

  showPlaylist() {
    this.router.navigate(['/playlists', this.playlist.id]);
  }

  subscribed = (event) => {
    this.democraylistService.subscripbedToPlaylist(this.playlist.id)
      .subscribe(data => {
        this.playlist.subscribed = true;
        this.router.navigate(['playlists', this.playlist.id]);
      });
  }

  unsubscribed = (event) => {
    this.democraylistService.unsubscripbedToPlaylist(this.playlist.id)
      .subscribe(data => {
        this.playlist.subscribed = false;
        this.router.navigate(['/']);
      });
  }

  myPlaylist(): boolean {
    return this.playlist.user_id === JSON.parse(localStorage.getItem('user')).id;
  }

  openWithSpotify = (event) => {
    window.open(this.playlist.uri, '_blank');
  }

  openStats = (event) => {
    this.router.navigate(['/playlists', this.playlist.id, 'stats']);
  }
}

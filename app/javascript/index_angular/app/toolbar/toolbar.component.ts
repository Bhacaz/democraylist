import {Component, OnDestroy, OnInit} from '@angular/core';
import {MenuItem} from 'primeng/api';
import {DemocraylistService} from '../democraylist/democraylist.service';
import {Router} from '@angular/router';
import {LocalstorageService} from '../common/localstorage.service';
import templateString from './toolbar.component.html'
import stylesString from './toolbar.component.scss'

@Component({
  selector: 'app-toolbar',
  template: templateString,
  styles: [stylesString]
})
export class ToolbarComponent implements OnInit, OnDestroy {

  user;
  menuItems: MenuItem[];
  localstorageChangingSubscription;

  constructor(
    private democraylistService: DemocraylistService,
    private router: Router,
    private localstorageService: LocalstorageService
  ) {
    this.localstorageChangingSubscription = this.localstorageService.localStorageChanging().subscribe(data => {
      if (data.key === 'user' && data.action === 'remove') {
        this.user = null;
      } else if (data.key === 'user' && data.action === 'set') {
        this.user = JSON.parse(localStorage.getItem('user'));
      }
    });
  }

  ngOnInit(): void {
    this.user = JSON.parse(localStorage.getItem('user'));
    this.menuItems = [
      {label: 'Logout', icon: 'fa-solid fa-sign-out', command: this.logoutEvent}
    ];
  }

  ngOnDestroy() {
    // unsubscribe to ensure no memory leaks
    this.localstorageChangingSubscription.unsubscribe();
  }

  logoutEvent = (event) =>  {
    this.democraylistService.logoutUser().subscribe(data => {
      this.localstorageService.removeItem('user');
      this.localstorageService.removeItem('access_token');
      this.router.navigate(['/login']);
    });
  }
}

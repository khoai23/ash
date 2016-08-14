import <QuestLib.ash>;

boolean deityKey() {
	int needed = item_amount($item[fat loot token]);
	if(have_item($item[Boris's key])) needed+=1;
	if(have_item($item[Jarlsberg's key])) needed+=1;
	if(have_item($item[Sneaky Pete's key])) needed+=1;
	//needed -= item_amount($item[Sneaky Pete's key]);
	if(needed>=3) {
		if(!have_item($item[Boris's key])) buy($item[Boris's key].seller,1,$item[Boris's key]);
		if(!have_item($item[Jarlsberg's key])) buy($item[Jarlsberg's key].seller,1,$item[Jarlsberg's key]);
		if(!have_item($item[Sneaky Pete's key])) buy($item[Sneaky Pete's key].seller,1,$item[Sneaky Pete's key]);
		return true;
	} if(needed==2) {
		if(acquire_token()) return true;
		return false;
	} else {
		print_warning("You need "+(3-needed)+" more token.");
		return false;
	} 
}

void borisKey() {
	if(have_item($item[Boris's key])) {
		print_quest_complete("Have Boris's key.");
		return;
	}
	if(!have_item($item[Boris's key]) && !have_item($item[fat loot token])) {
		acquire_token();
	}
	if(!have_item($item[Boris's key])) buy($item[Boris's key].seller,1,$item[Boris's key]);
}

void jarlsbergKey() {
	if(have_item($item[Jarlsberg's key])) {
		print_quest_complete("Have Jarlsberg's key.");
		return;
	}
	if(!have_item($item[Jarlsberg's key]) && !have_item($item[fat loot token])) {
		acquire_token();
	}
	if(!have_item($item[Jarlsberg's key])) buy($item[Jarlsberg's key].seller,1,$item[Jarlsberg's key]);
}

void sneakyPeteKey() {
	if(have_item($item[Sneaky Pete's key])) {
		print_quest_complete("Have Sneaky Pete's key.");
		return;
	}
	if(!have_item($item[Sneaky Pete's key]) && !have_item($item[fat loot token])) {
		acquire_token();
	}
	if(!have_item($item[Sneaky Pete's key])) buy($item[Sneaky Pete's key].seller,1,$item[Sneaky Pete's key]);
}

void starKey() {
	if(have_item($item[Richard's star key])) {
		print_quest_complete("Have Richard's star key.");
		return;
	}
	set_backup_state();
	maximize_item();
	while(!have_item($item[Richard's star key]) &&
			!(have_item($item[star chart]) && item_amount($item[star])>=8 && item_amount($item[line])>=7)) {
		while_abort();
		adventure(1,$location[The Hole In The Sky]);
	}
	get_backup_state();
	if(!have_item($item[Richard's star key])) create(1,$item[Richard's star key]);
}

boolean canMakeDigitalKey() {
	int white_pixel = item_amount($item[white pixel]);
	int makeable_pixel = item_amount($item[green pixel]);
	if(makeable_pixel>item_amount($item[blue pixel])) makeable_pixel = item_amount($item[blue pixel]);
	if(makeable_pixel>item_amount($item[red pixel])) makeable_pixel = item_amount($item[red pixel]);
	return (white_pixel+makeable_pixel)>=30;
}

void digitalKey() {
	if(have_item($item[digital key])) {
		print_quest_complete("Have digital key.");
		return;
	}
	set_backup_state();
	maximize_item();
	if(equipped_amount($item[continuum transfunctioner])==0 && !have_item($item[continuum transfunctioner])) {
		set_choices(664,1);
		run_choice(visit_url("place.php?whichplace=forestvillage&action=fv_mystic"));
	}
	if(equipped_amount($item[continuum transfunctioner])==0)
		equip($slot[acc3],$item[continuum transfunctioner]);
	while(!have_item($item[digital key]) && !canMakeDigitalKey()) {
		while_abort();
		adventure(1,$location[8-Bit Realm]);
	}
	get_backup_state();
	if(!have_item($item[digital key])) create(1,$item[digital key]);
}

void skeletonKey() {
	if(have_item($item[skeleton key])) {
		print_quest_complete("Have skeleton key.");
		return;
	}
	while(!have_item($item[skeleton key]) && !(have_item($item[loose teeth]) && have_item($item[skeleton bone]))) {
		while_abort();
		adventure(1,$location[The VERY Unquiet Garves]);
	}
	if(!have_item($item[skeleton key])) create(1,$item[skeleton key]);
}

void main() {
	if(!have_item($item[digital key])) {
		digitalKey();
	} else {
		print_goal_complete("Digital key acquired.");
	}
	
	if(!have_item($item[skeleton key])) {
		skeletonKey();
	} else {
		print_goal_complete("Skeleton key acquired.");
	}
	
	if(!deityKey()) {
		//vprint("You don't have enough tokens.","red",1);
	} else {
		print_goal_complete("Deity keys acquired.");
	}
	if(!have_item($item[Richard's star key])) {
		if(my_level()<10) abort("Not enough level to even try for star key.");
		starKey();
	} else {
		print_goal_complete("Star key acquired.");
	}
}
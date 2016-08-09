import <QuestLib.ash>;
import <Level 04.ash>;

int checkBasementNoncombat() {
	string lastEncounter = get_property("lastEncounter");
	if(lastEncounter == "You Don't Mess Around with Gym") return 1; 
	if(lastEncounter == "Out in the Open Source") return 2;
	if(lastEncounter == "The Fast and the Furry-ous") return 3;
	if(lastEncounter == "Arise!") return 4;
	return 0;
}

void open_Basement () {
	cli_execute("checkpoint");
	// go dumbell route if no amulet/umbrella
	if((item_amount($item[amulet of extreme plot significance])==0) && (item_amount($item[titanium assault umbrella])==0)) {
		set_choices(670,1);
		vprint("Searching for dumbbell. Dum dumb dumbb.","blue",1);
	} else if(item_amount($item[amulet of extreme plot significance])>0) {
		//equip($slot[acc3],$item[amulet of extreme plot significance]);
		set_choices(670,5);
		vprint("Have amulet.","blue",1);
	} 
	set_choices(671,4);
	if(item_amount($item[titanium assault umbrella])>0) {
		//equip($slot[weapon],$item[titanium assault umbrella]);
		set_choices(669,4);
		vprint("Have umbrella.","blue",1);
	} 
	
	int lastAdv = checkBasementNoncombat();
	vprint("Adventuring in the basement..","blue",1);
	while(lastAdv!=4) {
		while_abort();
		adv1($location[The Castle in the Clouds in the Sky (Basement)],-1,"");
		lastAdv = checkBasementNoncombat();
		if((have_item($item[amulet of extreme plot significance])) && (lastAdv==1)) {
			set_choices(670,4);
			equip($slot[acc3],$item[amulet of extreme plot significance]);
			vprint("Start using amulet.","olive",5);
			adv1($location[The Castle in the Clouds in the Sky (Basement)],-1,"");	
			break;
		} else if(have_item($item[titanium assault umbrella]) && (lastAdv==3)) {
			set_choices(669,1);
			equip($slot[weapon],$item[titanium assault umbrella]);
			vprint("Wield umbrella.","olive",5);
			adv1($location[The Castle in the Clouds in the Sky (Basement)],-1,"");	
			break;
		} else if(have_item($item[massive dumbbell])) {
			set_choices(671,1);
			set_choices(669,1);
			set_choices(670,3);
		} else {
			set_choices(670,1);
		}
	}
	vprint("Ground floor opened.","green",1);
	cli_execute("outfit checkpoint");
}

boolean openedTopFloor() {
	return getLastEncounter() == "Top of the Castle, Ma";
}

void open_GroundFloor() {
	set_choices(1026,2);
	vprint("Adventuring in the ground floor..","blue",1);
	fulfill_condition("openedTopFloor",$location[The Castle in the Clouds in the Sky (Ground Floor)]);
	/*
	while(get_property("lastEncounter") != "Top of the Castle, Ma") {
		while_abort();
		adventure(1,$location[The Castle in the Clouds in the Sky (Ground Floor)]);
	}
	*/
	vprint("Top floor opened.","green",1);
}

boolean encounteredWheel() {
	return getLastEncounter() == "Keep On Turnin' the Wheel in the Sky";
}

void spinWheel() {
	cli_execute("checkpoint");
	if(item_amount($item[Mohawk wig])>0 && user_confirm("Do you wish to wear a Mohawk wig?")) {
		equip($item[Mohawk wig]);
		set_choices(678,1);
		set_choices(676,4);
	} 
	if(item_amount($item[model airship])>0) {
		set_choices(677,1);
		set_choices(675,4);
	} else if(item_amount($item[Mohawk wig])==0){
		// have neither, search and use bass record instead
		set_choices(676,3);
		set_choices(678,4);
		set_choices(675,1);
		set_choices(677,4);
	}
	set_choices(679,1);
	fulfill_condition("encounteredWheel",$location[The Castle in the Clouds in the Sky (Top Floor)]);
	/*
	while(get_property("lastEncounter") != "Keep On Turnin' the Wheel in the Sky") {
		while_abort();
		adv1($location[The Castle in the Clouds in the Sky (Top Floor)],-1,"");
	}
	*/
	cli_execute("outfit checkpoint");
	vprint("The wheel was spinned.","green",1);
}

void find_boneKnife() {
	set_choices(1026,2);
	if(item_amount($item[electric boning knife])>0) {
		vprint("Electric boning knife already found.","green",1);
		return;
	}
	obtain(1, $item[electric boning knife], $location[The Castle in the Clouds in the Sky (Ground Floor)]);
}

boolean skyHoleAvailable() {
	return have_item($item[steam-powered model rocketship]);
}

void unlock_skyHole() {
	// set the corresponding choice
	set_choices(677,2);
	set_choices(675,4);
	set_choices(678,3);
	set_choices(676,4);
	fulfill_condition("skyHoleAvailable",$location[The Castle in the Clouds in the Sky (Top Floor)]);
	/*
	while(!skyHoleAvailable()) {
		while_abort();
		adv1($location[The Castle in the Clouds in the Sky (Top Floor)],-1,"");
	}
	*/
}

void TrashQuest()
{
	if (my_level() >= 10)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"The Rain on the Plains is Mainly Garbage"))
		{
			if (!contains_text(visit_url("plains.php"),"beanstalk.gif"))
			{
				if (!have_item($item[enchanted bean]))
				{
					if(!contains_text(visit_url("plains.php"),"bathole_4.gif") && !contains_text(visit_url("plains.php"),"bathole_3.gif")) {
						BatQuest();
					}
					obtain(1, $item[enchanted bean], $location[The Beanbat Chamber]);
				}

				visit_url("place.php?whichplace=plains&action=garbage_grounds");
			}

			if (contains_text(visit_url("plains.php"),"beanstalk.gif"))
			{
				if (!have_item($item[S.O.C.K.])) {
					obtain(1, $item[S.O.C.K.], $location[The Penultimate Fantasy Airship]);
				}
				else {
					vprint("You have found your personal airship. Go you!","green",1);
				}
				
				buffer try_topfloor = visit_url("adventure.php?snarfblat=324");
				
				if(contains_text(try_topfloor,"You have to learn to walk before you can learn to fly.")) {
					vprint("Only basement opened. Solving this predicament...","olive",5);
					open_Basement();
					open_GroundFloor();
				} else if(contains_text(try_topfloor,"figure out some other way")) {
					vprint("Ground floor opened. Searching for stairs...","olive",5);
					open_GroundFloor();
				} else {
					run_combat();
				}
				vprint("Top floor opened. Find the workshift wheel...","green",1);
				spinWheel();
			}

			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Rain on the Plains is Mainly Garbage"))
		{
			vprint("You have already completed the level 10 quest.","green",1);
		}
		else
		{
			vprint("The level 10 quest is not currently available.","black",1);
		}
	}
	else
	{
		vprint("You must be at least level 10 to attempt this quest.","red",1);
	}
}

void main()
{
	TrashQuest();
	
	if(!have_item($item[steam-powered model rocketship]) && my_level()>=10 && user_confirm("Do you wish to open the hole in the sky?")) {
		unlock_skyHole();
	} else {
		vprint("Sky already accessible.","green",1);
	}
	
	if(!have_item($item[electric boning knife]) && !contains_text(visit_url("questlog.php?which=2"),"The Ultimate Final Epic Conflict of the Ages")) {
		if(my_level()>=13 && user_confirm("Do you wish to find the bone knife now?"))
			find_boneKnife();
		else {
			vprint("You should wait until the lair is opened.","blue",1);
		}
	} else {
		vprint("You had the electric knife.","green",1);
	}
}
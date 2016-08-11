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
	set_backup_state();
	// go dumbell route if no amulet/umbrella
	if((item_amount($item[amulet of extreme plot significance])==0) && (item_amount($item[titanium assault umbrella])==0)) {
		set_choices(670,1);
		print_goal("Searching for dumbbell. Dum dumb dumbb.");
	} else if(item_amount($item[amulet of extreme plot significance])>0) {
		print_debug("Set choice to return later - amulet");
		set_choices(670,5);
		print_goal("Have amulet. Ready for parachuting.");
	} 
	set_choices(671,4);
	if(item_amount($item[titanium assault umbrella])>0) {
		print_debug("Set choice to return later - umbrella");
		set_choices(669,4);
		print_goal("Have umbrella. Finding secret compartment.");
	} 
	
	int lastAdv = checkBasementNoncombat();
	print_goal("Adventure in the basement.");
	while(lastAdv!=4) {
		while_abort();
		adv1($location[The Castle in the Clouds in the Sky (Basement)]);
		lastAdv = checkBasementNoncombat();
		if((have_item($item[amulet of extreme plot significance])) && (lastAdv==1)) {
			set_choices(670,4);
			equip($slot[acc3],$item[amulet of extreme plot significance]);
			print_debug("Start using amulet.");
			adv1($location[The Castle in the Clouds in the Sky (Basement)]);	
			break;
		} else if(have_item($item[titanium assault umbrella]) && (lastAdv==3)) {
			set_choices(669,1);
			equip($slot[weapon],$item[titanium assault umbrella]);
			print_debug("Wield umbrella.");
			adv1($location[The Castle in the Clouds in the Sky (Basement)]);	
			break;
		} else if(have_item($item[massive dumbbell])) {
			print_debug("Have dumbbell, changing choice.");
			set_choices(671,1);
			set_choices(669,1);
			set_choices(670,3);
		} else {
			print_debug("Waiting until meet a choice.");
		}
	}
	print_goal_complete("Ground floor opened.");
	get_backup_state();
}

boolean openedTopFloor() {
	return get_last_encounter() == "Top of the Castle, Ma";
}

void open_GroundFloor() {
	set_choices(1026,2);
	print_goal("Adventure in the ground floor.");
	fulfill_condition("openedTopFloor",$location[The Castle in the Clouds in the Sky (Ground Floor)]);
	print_goal_complete("Top floor opened.");
}

boolean encounteredWheel() {
	return get_last_encounter() == "Keep On Turnin' the Wheel in the Sky";
}

void spinWheel() {
	set_backup_state();
	if(have_item($item[Mohawk wig]) && user_confirm("Do you wish to wear a Mohawk wig?")) {
		print_debug("Set choice to use Mohawk wig on Punk/Proc.");
		equip($item[Mohawk wig]);
		set_choices(678,1);
		set_choices(676,4);
	} 
	if(have_item($item[model airship])) {
		print_debug("Set choice to use model airship on Goth/Steam.");
		set_choices(677,1);
		set_choices(675,4);
	} 
	if(!have_item($item[Mohawk wig]) && equipped_amount($item[Mohawk wig])==0 && !have_item($item[model airship])){
		// have neither, search and use bass record instead
		print_debug("Set choice to search and use record.");
		set_choices(676,3);
		set_choices(678,4);
		set_choices(675,1);
		set_choices(677,4);
	}
	print_debug("Set choice to turn wheel.");
	set_choices(679,1);
	fulfill_condition("encounteredWheel",$location[The Castle in the Clouds in the Sky (Top Floor)]);
	get_backup_state();
	print_goal_complete("The wheel was spinned.");
}

void find_boneKnife() {
	print_debug("Set choice to take knife.");
	set_choices(1026,2);
	if(item_amount($item[electric boning knife])>0) {
		print_quest_complete("Electric boning knife already found.");
		return;
	}
	obtain(1, $item[electric boning knife], $location[The Castle in the Clouds in the Sky (Ground Floor)]);
}

boolean skyHoleAvailable() {
	return have_item($item[steam-powered model rocketship]);
}

void unlock_skyHole() {
	// set the corresponding choice
	print_debug("Set choice to get rocketship from every noncombat.");
	set_choices(677,2);
	set_choices(675,4);
	set_choices(678,3);
	set_choices(676,4);
	fulfill_condition("skyHoleAvailable",$location[The Castle in the Clouds in the Sky (Top Floor)]);
}

void TrashQuest()
{
	if (my_level() >= 10)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"The Rain on the Plains is Mainly Garbage")) {
			if (!contains_text(visit_url("plains.php"),"beanstalk.gif")) {
				if (!have_item($item[enchanted bean])) {
					if(!contains_text(visit_url("plains.php"),"bathole_4.gif") && !contains_text(visit_url("plains.php"),"bathole_3.gif")) {
						BatQuest();
					}
					obtain(1, $item[enchanted bean], $location[The Beanbat Chamber]);
				}

				visit_url("place.php?whichplace=plains&action=garbage_grounds");
			}

			if (contains_text(visit_url("plains.php"),"beanstalk.gif")) {
				if (!have_item($item[S.O.C.K.])) {
					set_choices(182,5); 
					print_debug("Set choice to get model airship and then combat.");
					obtain(1, $item[S.O.C.K.], $location[The Penultimate Fantasy Airship]);
				} else {
					print_goal_complete("You have found your personal airship. Go you!");
				}
				
				buffer try_topfloor = visit_url("adventure.php?snarfblat=324");
				
				if(contains_text(try_topfloor,"You have to learn to walk before you can learn to fly.")) {
					print_goal("Only basement opened. Solve this predicament.");
					open_Basement();
					open_GroundFloor();
				} else if(contains_text(try_topfloor,"figure out some other way")) {
					print_goal("Ground floor opened. Search for stairs.");
					open_GroundFloor();
				} else {
					run_combat();
				}
				print_goal_complete("Top floor opened. Find the workshift wheel.");
				spinWheel();
			}

			council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"The Rain on the Plains is Mainly Garbage")) {
			print_quest_complete("You have already completed the level 10 quest.");
		} else {
			print_warning("The level 10 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 10 to attempt this quest.");
	}
}

void main()
{
	TrashQuest();
	
	if(!have_item($item[steam-powered model rocketship]) && my_level()>=10 && user_confirm("Do you wish to open the hole in the sky?")) {
		unlock_skyHole();
	} else {
		print_quest_complete("Sky already accessible.");
	}
	
	if(!have_item($item[electric boning knife]) && !contains_text(visit_url("questlog.php?which=2"),"The Ultimate Final Epic Conflict of the Ages")) {
		if(my_level()>=13 && user_confirm("Do you wish to find the bone knife now?"))
			find_boneKnife();
		else {
			print_not_qualified("You should wait until the lair is opened.");
		}
	} else {
		print_quest_complete("You had the electric knife.");
	}
}
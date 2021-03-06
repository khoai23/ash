import <QuestLib.ash>;

boolean checkTwinPeakProgress() {
	int twinPeakProgress = to_int(get_property("twinPeakProgress"));
	if((twinPeakProgress & 1) == 0) {
		if(elemental_resistance($element[stench]) < 40.0) {
			maximize_stench();
		}
		if(elemental_resistance($element[stench]) < 40.0) {
			abort("Ready for choice 1, but not enough resistance.");
		}
		print_debug("Set choice to stench.");
		set_choices(606,1);
		set_choices(607,1);
	} else if((twinPeakProgress & 2) == 0) {
		if((item_drop_modifier() < 50 && have_effect($effect[Brother Flying Burrito's Blessing])==0) || (item_drop_modifier() < 20)) {
			abort("Ready for choice 2, but not enough +item.");
		}
		print_debug("Set choice to +item.");
		set_choices(606,2);
		set_choices(608,1);
	} else if((twinPeakProgress & 4) == 0) {
		if(!have_item($item[Jar of Oil])) {
			if(!use(12,$item[bubblin' crude])) {	
				abort("Ready for choice 3, but not enough oil piece to make jar of oil.");
			}
		}
		print_debug("Set choice to jar of oil.");
		set_choices(606,3);
		set_choices(609,1);
		set_choices(616,1);
	} else if(twinPeakProgress == 7) {
		if(initiative_modifier()<40) {
			if(have_item($item[Lord Spookyraven's ear trumpet])) {
				equip($slot[acc3],$item[Lord Spookyraven's ear trumpet]);
			}
		}
		if(initiative_modifier()<40) {
			abort("Ready for choice 4, but not enough initiative.");
		}
		print_debug("Set choice to init.");
		set_choices(606,4);
		set_choices(610,1);
		set_choices(617,1);
	} else if(twinPeakProgress>7){
		print_debug("Set choice to escape, which shouldn't happen anyway.");
		set_choices(606,0);
	} else {
		abort("Something had messed up the variable. Aborting.");
	}
	return contains_text(visit_url("place.php?whichplace=highlands"),"fire2.gif");
}

boolean bridgeComplete() {
	print_debug("Progress: "+get_property("chasmBridgeProgress"));
	return get_property("chasmBridgeProgress").to_int() >= 30;
}

void buildBridge() {
	if(have_item($item[smut orc keepsake box])) {
		use(1,$item[smut orc keepsake box]);
	}
	visit_url("place.php?whichplace=orc_chasm&action=bridge"+get_property("chasmBridgeProgress"));
}

boolean oilPeakLit() {
	return contains_text(visit_url("place.php?whichplace=highlands"),"fire3.gif");
}

boolean ghostPeakReady() {
	return (to_int(get_property("booPeakProgress")) - item_amount($item[a-boo clue])*30)<=0;
}

boolean ghostPeakComplete() {
	return to_int(get_property("booPeakProgress")) == 0;
}

void LOLQuest()
{
	if (my_level() >= 9) {
		council();

		if (contains_text(visit_url("questlog.php?which=1"),"There Can Be Only One Topping")) {
		
			if (!contains_text(visit_url("place.php?whichplace=orc_chasm"),"cross_chasm.gif")) {

				if ((!have_item($item[abridged dictionary])) && (!have_item($item[bridge]))) {
					if(contains_text(visit_url("forestvillage.php"),"ut_cottage_quest.gif")) {
						print_goal("Agree to help the untinker.");
						visit_url("place.php?whichplace=forestvillage&action=fv_untinker_quest&preaction=screwquest");
					}
					if(contains_text(visit_url("questlog.php?which=1"),"Driven Crazy")) {
						print_goal("Search for screwdriver.");
						if(!knoll_available()) obtain_item(1,$item[rusty screwdriver],$location[The Degrassi Knoll Garage]);
						else visit_url("place.php?whichplace=knoll_friendly&action=dk_innabox");
						visit_url("place.php?whichplace=forestvillage&action=fv_untinker");
					}
					obtain_outfit("swashbuckling getup",$location[The Obligatory Pirate's Cove]);
	
					set_backup_state();
					if(item_amount($item[pirate fledges])>0 && can_equip($item[pirate fledges])) {
						equip($slot[acc3],$item[pirate fledges]);
					} else if (have_outfit("swashbuckling getup")) {
						outfit("swashbuckling getup");
					} 
					
					if(contains_text(visit_url("shop.php?whichshop=bartlebys"),"abridged")) {
						buy(1, $item[abridged dictionary]);
					} else {
						print_not_qualified("Dictionary already purchased.");
					}
					
					get_backup_state();
				}
				
				if (have_item($item[abridged dictionary])) {
					cli_execute("untinker abridged dictionary");
				}
				visit_url("place.php?whichplace=orc_chasm&action=label1");
				
				print_goal("Building a bridge through the chasm.");
				fulfill_condition("bridgeComplete","buildBridge",$location[The Smut Orc Logging Camp]);
				
			} else {
				print_quest_complete("Bridge finished. Continuing to next part of the quest..");
			}
			
			visit_url("place.php?whichplace=highlands&action=highlands_dude");

			if (!oilPeakLit()) {
				print_goal("Dealing with oil peak.");
				set_backup_state();
				maximize_ml();
				fulfill_condition("oilPeakLit",$location[Oil Peak]);
				get_backup_state();
				//cli_execute("use 12 bubblin' crude");
			} else {
				print_goal_complete("Oil peak lighted.");
			}
			
			if (!checkTwinPeakProgress()) {
				print_goal("Dealing with twin peak.");
				set_backup_state();
				//set_choices(605,1);
				fulfill_condition("checkTwinPeakProgress",$location[Twin Peak]);
				get_backup_state();
			} else {
				print_goal_complete("Twin peak lighted.");
			}
			
			if (!contains_text(visit_url("place.php?whichplace=highlands"),"fire1.gif")) {
				print_goal("Search for clues to light the peak(faster).");
				
				int preparation = to_int(get_property("booPeakProgress")) - item_amount($item[a-boo clue])*30;
				if(preparation>0 && !user_confirm("Have you prepare yourselves to kill ghost?")) {
					abort("Please make your preparation and come again.");
				}
				
				set_backup_state();
				maximize_item();
				fulfill_condition("ghostPeakReady",$location[A-Boo Peak]);
				
				if(maximize_for_ghost()) {
					print_goal("Use a-boo clues.");
					set_choices(611,1);
					while(have_item($item[a-boo clue]) && !ghostPeakComplete()) {
						restore_hp(my_maxhp());
						while_abort();
						use(1,$item[a-boo clue]);
						adventure(1,$location[A-Boo Peak]);
					}
				} else if(user_confirm("Do you wish to bruteforce the peak?")) {
					print_goal("Remove ghost, one step at a time");
					get_backup_state();
					fulfill_condition("ghostPeakComplete",$location[A-Boo Peak]);
				} else {
					res_abort("Consider your options.");
				}
				
				if(to_int(get_property("booPeakProgress"))==0)
					adv1($location[A-Boo Peak]);
				else	
					print_minor_warning("How the hell did you get here?");
				get_backup_state();
			} else {
				print_goal_complete("Ghost peak lighted.");
			}
			
			visit_url("place.php?whichplace=highlands&action=highlands_dude");
			
            council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"There Can Be Only One Topping")) {
			print_quest_complete("You have already completed the level 9 quest.");
		} else {
			print_warning("The level 9 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 9 to attempt this quest.");
	}
}

void main()
{
	LOLQuest();
}

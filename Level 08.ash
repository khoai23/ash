import <QuestLib.ash>;
import <zlib.ash>;

int maxprice = 1000;
boolean slope_complete = false;

string noncom_slope_complete(int round, string opp, string text) {
	if(text.contains_text("Perfect Melancholy")) {
		slope_complete = true;
	}
	return get_ccs_action(round);
}

boolean skiingDone() {
	return get_last_encounter() == "3 eXXXtreme 4ever 6pack";
}

boolean haveAllNinjaGear() {
	return have_item($item[ninja rope]) && have_item($item[ninja carabiner]) && have_item($item[ninja crampons]);
}

void TrapperQuest()
{
    if (my_level() >= 8) {
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Am I My Trapper's Keeper"))
		{
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	
			if (contains_text(visit_url("questlog.php?which=1"),"wedges of goat cheese")) {
				print_goal("Searching for ore & cheese.");
				item ore;
				if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "chrome ore")) {
					ore = $item[chrome ore];
				} else if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "asbestos ore")) {
					ore = $item[asbestos ore];
				} else if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "linoleum ore")) {
					ore = $item[linoleum ore];
				} else {
					abort("Cannot find ore");
				}
				
				if(item_amount(ore) < 3) {
					if(pulls_remaining()>=3 && user_confirm("Would you like to pull "+to_string(ore)+"?")) {
						// pull ore, will purchase if not enough
						print_goal("Pull ore from storage.");
						if((storage_amount(ore) + item_amount(ore)) < 3) {
							if(buy_using_storage(3-(storage_amount(ore) + item_amount(ore)), ore, maxprice) < 3) 
								abort("Cannot autobuy ore, please manually purchase from the mall.");
						}
						if(!take_storage(3-item_amount(ore),ore)) abort("Cannot pull ore.");
					} else {
						if(!have_outfit("mining gear")) {
							print_goal("Farming for miner outfit.");
							obtain_outfit("mining gear",$location[Itznotyerzitz Mine]);
						}
						print_goal_complete("Outfit farmed, ready for mining.");
						abort("Mine it yourself. Fag.");
					}
				} else {
					print_goal_complete("Have enough ore.");
				}
				
				if(item_amount($item[goat cheese]) < 3) {
					set_backup_state();
					print_goal("Farming for cheese.");
					maximize_item();
					obtain_item(3,$item[goat cheese],$location[The Goatlet]);
					get_backup_state();
				} else {
					print_goal_complete("Have enough cheese.");
				}
	
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			} else {
				print_quest_complete("First part of the quest completed.");
			}
	
			if (contains_text(visit_url("questlog.php?which=1"),"investigate the top"))
			{
				boolean have_outfit = false;
				print_goal("Find your way to the peak.");
		
				set_backup_state();
				if(elemental_resistance($element[cold]) > 48.2 && have_familiar($familiar[Jumpsuited Hound Dog])) {
					// 5 resist =  48.3%
					print_goal("Have +combat, going ninja.");
					if(have_item($item[ninja carabiner]) && have_item($item[ninja crampons]) && have_item($item[ninja rope])) {
						print_goal_complete("Already have ninja climbing set.");
					} else if(pulls_remaining() >= 3 && user_confirm("Pulling ninja climbing set?")) {
						if(!have_item($item[ninja carabiner])) take_storage(1,$item[ninja carabiner]);
						if(!have_item($item[ninja crampons])) take_storage(1,$item[ninja crampons]);
						if(!have_item($item[ninja rope])) take_storage(1,$item[ninja rope]);
					} else {
						print_minor_warning("Attempt to raise combat rate, may gimp your combat capacity.");
						maximize_com();
						print_goal("Searching for ninja gear.");
						fulfill_condition("haveAllNinjaGear",$location[Lair of the Ninja Snowmen]);
					}
				} else {
					// default skiing - searching for outfit
					print_goal("Don't have reliable familiar, go slope.");
					obtain_outfit("eXtreme Cold-Weather Gear",$location[The eXtreme Slope]);
					
					// commence skiing
					print_goal("Skiing on slope.");
					if(have_outfit("eXtreme Cold-Weather Gear")) {
						outfit("eXtreme Cold-Weather Gear");
					}
					fulfill_condition("skiingDone",$location[The eXtreme Slope]);
				}

				print_goal("Climb the peak.");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
	
				get_backup_state();
			} else {
				print_quest_complete("Second part of the quest completed.");
			}
			
			if (contains_text(visit_url("questlog.php?which=1"),"Icy Peak")) {
				set_backup_state();
				if(elemental_resistance($element[cold]) < 48.3) {
					print_minor_warning("Attempt to automate resist, may gimp your combat capacity.");
					if(have_outfit("eXtreme Cold-Weather Gear")) {
						outfit("eXtreme Cold-Weather Gear");
					} else {
						maximize_cold();
					}
				} else {
					print_goal_complete("You have sufficient cold protection. Go and get these yeti rolling!");
				}
				//print("Find and kill Groar..","blue");
				
				print_goal("Kill first yeti:");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				print_goal("Kill second yeti:");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				print_goal("Kill third yeti:");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				print_goal("Kill Groar:");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				
				get_backup_state();
			}
	
			print_goal("Finish quest.");
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	
			council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"Am I My Trapper's Keeper?")) {
			print_quest_complete("You have already completed the level 8 quest.");
		} else {
			print_warning("The level 8 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 8 to attempt this quest.");
	}
}

void main()
{
	TrapperQuest();
}
import <QuestLib.ash>;

void sonarUse() {
	if(have_item($item[sonar-in-a-biscuit]))
		use(1,$item[sonar-in-a-biscuit]);
	if(!have_item($item[enchanted bean]) && 
	(contains_text(visit_url("bathole.php"),"bathole_4.gif") || contains_text(visit_url("bathole.php"),"bathole_3.gif")))
		obtain_item(1,$item[enchanted bean],$location[The Beanbat Chamber]);
}

void BatQuest()
{  
	if (my_level() >= 4) {
		council();
	
		if (contains_text(visit_url("questlog.php?which=1"),"Ooh, I Think I Smell a Bat.")) {
			set_backup_state();
			// Try opening the way to the lair
			if(elemental_resistance($element[stench]) >= 10.00) {
				print_goal_complete("Have enough resistance(1).");
			} else if(!have_item($item[Pine-Fresh air freshener]) &&
				 user_confirm("Do you wish to find stench resistance in the entryway instead?")) {
				maximize_item();
				obtain_item(1,$item[Pine-Fresh air freshener], $location[The Bat Hole Entrance]);
				get_backup_state();
			} else {
				if(!have_item($item[Pine-Fresh air freshener]) || !equip($slot[acc3],$item[Pine-Fresh air freshener]))
					res_abort("Please boost stench resistance and try again.");
			}
			
			if(elemental_resistance($element[stench]) >= 10.00 && !contains_text(visit_url("bathole.php"),"bathole_4.gif")) {
				print_goal("Finding the way to the boss room");
				open_location("bathole.php","bathole_4.gif","sonarUse",$location[Guano Junction]);
				print_debug("Opened way to the boss room");
			}
			
			// killing Boss Bat and its retinue
            if (contains_text(visit_url("bathole.php"),"The Boss Bat's Lair (1)")) {
				maximize_meat();
				if (user_confirm("Try for the Boss Bat britches?")) {
					change_mcd(4);
				} else if (user_confirm("Try for the Boss Bat bling?")) {
					change_mcd(8);
				} else if ((canadia_available()) && (!contains_text(visit_url("trophies.php"),"Boss Boss"))
					&& user_confirm("Try for the Boss Boss trophy?")) {
						change_mcd(11);
				}

				while (contains_text(visit_url("bathole.php"),"The Boss Bat's Lair (1)")) {
					while_abort();
					adventure(1, $location[The Boss Bat's Lair]);
				}
				get_backup_state();
			} else {
				print_quest_complete("The Boss Bat had been vanquished. You diligent person you.");
			}
			
			council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"Ooh, I Think I Smell a Bat.")) {
			print_quest_complete("You have already completed the level 4 quest.");
		} else {
			print_warning("The level 4 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 4 to attempt this quest.");
	}
}

void main()
{
	BatQuest();
}

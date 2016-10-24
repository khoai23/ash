import <QuestLib.ash>;
import <Spookyraven Upstairs.ash>;

int outfit_c;

boolean side_frat = true;
boolean side_hippy = false;

boolean checkBeePollen() {
	return have_item($item[guy made of bee pollen]) || (last_monster()==$monster[Guy Made Of Bees]);
}

string beeKiller(boolean side) {
	string page = visit_url(to_url($location[The Haunted Bathroom]));
	if(contains_text(page,"Combat")) {
		if(contains_text(page,"Guy Made Of Bees")) {
			if(side==side_frat) {
				if(have_skill($skill[Ambidextrous Funkslinging]))
					page = throw_items($item[rock band flyers],$item[antique hand mirror]);
				else {
					page = throw_item($item[rock band flyers]);
					if(!contains_text(page,"You slink away, dejected and defeated.")) {
						page = throw_item($item[antique hand mirror]);
					}
				}
			} else {
				if(have_skill($skill[Ambidextrous Funkslinging]))
					page = throw_items($item[jam band flyers],$item[antique hand mirror]);
				else {
					page = throw_item($item[jam band flyers]);
					if(!contains_text(page,"You slink away, dejected and defeated.")) {
						page = throw_item($item[antique hand mirror]);
					}
				}
			}
		} else {
			page = run_combat();
		}
	} else {
		page = run_choice(page);
	}
	return page;
}

void runFlyerDefault(boolean side) {
	if(get_property("sidequestArenaCompleted")=="fratboy" || get_property("sidequestArenaCompleted")=="hippy") {
		print_quest_complete("Arena sidequest completed as " + get_property("sidequestArenaCompleted"));
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) {warOutfit = "War Hippy Fatigue"; outfit_c = 1; }
	set_backup_state();
	print_debug("Use outfit: " + warOutfit);
	outfit(warOutfit);
	visit_url("bigisland.php?place=concert");
	get_backup_state();
	
	int guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
	if(guyMadeOfBeesCount<4) {
		if(!user_confirm("You have only say TGMOB for " + guyMadeOfBeesCount + " times. Do you wish to find him anyway?")) {
			abort("Please do the flyer(ing) yourself.");
		}
	}
	
	if (!have_item($item[antique hand mirror]))	{
		set_bedroom_choices();
		print_goal("Find antique hand mirror.");
		obtain(1, $item[antique hand mirror], $location[The Haunted Bedroom]);
	}
	
	set_choices(105,3);
	print_goal("Flyer and kill the guy made of bees.");
	if(!have_skill($skill[Ambidextrous Funkslinging])) {
		print_minor_warning("You cannot funksling item, and may get beaten up.");
		if(have_familiar($familiar[Untamed Turtle]) && my_class()==$class[Turtle Tamer]) {
			use_familiar($familiar[Untamed Turtle]);
		} else if(have_familiar($familiar[Levitating Potato])) {
			use_familiar($familiar[Levitating Potato]);
		} 
	}
	maximize_noncom();
	custom_fight("checkBeePollen","beeKiller",side);
	
	outfit(warOutfit);
	visit_url("bigisland.php?place=concert");
	get_backup_state();
}

void dewormOrchard(boolean side) {
	if(get_property("sidequestOrchardCompleted")=="fratboy" || get_property("sidequestOrchardCompleted")=="hippy") {
		print_quest_complete("Orchard sidequest completed as "+get_property("sidequestOrchardCompleted"));
		return;
	}
	// save current outfit for adventuring
	set_backup_state();
	// determine outfit by which is available
	string war_outfit;
	if(side==side_hippy) war_outfit = "War Hippy Fatigue";
	else war_outfit = "Frat Warrior Fatigue";
	print_debug("Using outfit " + war_outfit);
	
	// use outfit to receive quest
	outfit(war_outfit);
	visit_url("bigisland.php?place=orchard&action=stand&pwd");	
	get_backup_state();
	
	print_goal("Kill the worm queen.");
	maximize_item();
	while (have_effect($effect[Filthworm Guard Stench]) == 0) {
      while (have_effect($effect[Filthworm Drone Stench]) == 0) {
         while (have_effect($effect[Filthworm Larva Stench]) == 0) {
			print_goal("Acquire hatchling scent gland.");
            obtain(1, $item[filthworm hatchling scent gland], $location[the hatching chamber]);
            while_abort();
            if (!use(1, $item[filthworm hatchling scent gland])) print_debug("You smell like a hatchling.");
         }
		 print_goal("Acquire drone scent gland.");
         obtain(1, $item[filthworm drone scent gland], $location[the feeding chamber]);
         while_abort();
         if (!use(1, $item[filthworm drone scent gland])) print_debug("You smell like a drone.");
      }
	  print_goal("Acquire guard scent gland.");
      obtain(1, $item[filthworm royal guard scent gland], $location[the royal guard chamber]);
      while_abort();
      if (!use(1, $item[filthworm royal guard scent gland])) print_debug("You smell like a guard.");
   }
   print_goal("Guard scent gland acquired. Killing filthworm queen.");
   obtain(1, $item[heart of the filthworm queen], $location[the filthworm queen's chamber]);
   print_goal_complete("Filthworm heart acquired.");
   
   outfit(war_outfit);
   // finish quest
   print_goal("Deliver heart to owner...");
   visit_url("bigisland.php?place=orchard&action=stand&pwd");	
   // receive meat
   visit_url("bigisland.php?place=orchard&action=stand&pwd");
   get_backup_state();
}

void bombSearch(boolean side) {
	if(get_property("sidequestLighthouseCompleted")=="fratboy" || get_property("sidequestLighthouseCompleted")=="hippy") {
		print_quest_complete("Lighthouse sidequest completed as " + get_property("sidequestLighthouseCompleted"));
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) warOutfit = "War Hippy Fatigue";
	set_backup_state();
	outfit(warOutfit);
	print_debug("Use outfit: " + warOutfit);
	print_goal("Meet bombmaker.");
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	print_goal("Searching for bomb barrels.");
	maximize_com();
	obtain_item(5, $item[barrel of gunpowder], $location[sonofa beach]);
	print_goal("Deliver payload.");
    visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	get_backup_state();
}

boolean haveAllTools() {
	return (have_item($item[molybdenum hammer]) && have_item($item[molybdenum crescent wrench]) &&
			  have_item($item[molybdenum pliers]) && have_item($item[molybdenum screwdriver]));
}

string searchTools() {
	buffer page;
	if(!have_item($item[molybdenum hammer])) {
		page = visit_url(to_url($location[Next to that Barrel with Something Burning in it]));
		if(!contains_text(page,"batwinged gremlin")) {
			page = run_combat();
		} else {
			while(!contains_text(page,"You win the fight!") && !contains_text(page,"You slink away, dejected and defeated.")) {
				if(contains_text(page,"does a bombing run over your head")) {
					// no hammer, end combat
					page = run_combat();
				} else if(contains_text(page,"whips out a hammer")) {
					// has hammer, use magnet
					page = throw_item($item[molybdenum magnet]);
				} else {
					// continue
					page = throw_item($item[spectre scepter]);
				}
			}
		}
	} else if(!have_item($item[molybdenum crescent wrench])) {
		page = visit_url(to_url($location[Over Where the Old Tires Are]));
		if(!contains_text(page,"erudite gremlin")) {
			page = run_combat();
		} else {
			while(!contains_text(page,"You win the fight!") && !contains_text(page,"You slink away, dejected and defeated.")) {
				if(contains_text(page,"make an automatic eyeball-peeler")) {
					// no wrench, end combat
					page = run_combat();
				} else if(contains_text(page,"whips out a crescent wrench")) {
					// has wrench, use magnet
					page = throw_item($item[molybdenum magnet]);
				} else {
					// continue
					page = throw_item($item[spectre scepter]);
				}
			}
		}
	} else if(!have_item($item[molybdenum pliers])) {
		page = visit_url(to_url($location[Near an Abandoned Refrigerator]));
		if(!contains_text(page,"spider gremlin")) {
			page = run_combat();
		} else {
			while(!contains_text(page,"You win the fight!") && !contains_text(page,"You slink away, dejected and defeated.")) {
				if(contains_text(page,"bites you in the fibula")) {
					// no pliers, end combat
					page = run_combat();
				} else if(contains_text(page,"whips out a pair of pliers")) {
					// has pliers, use magnet
					page = throw_item($item[molybdenum magnet]);
				} else {
					// continue
					page = throw_item($item[spectre scepter]);
				}
			}
		}
	} else if(!have_item($item[molybdenum screwdriver])) {
		page = visit_url(to_url($location[Out by that Rusted-Out Car]));
		if(!contains_text(page,"vegetable gremlin")) {
			page = run_combat();
		} else {
			while(!contains_text(page,"You win the fight!") && !contains_text(page,"You slink away, dejected and defeated.")) {
				if(contains_text(page,"off of itself and beats you")) {
					// no screwdriver, end combat
					page = run_combat();
				} else if(contains_text(page,"whips out a screwdriver")) {
					// has screwdriver, use magnet
					page = throw_item($item[molybdenum magnet]);
				} else {
					// continue
					page = throw_item($item[spectre scepter]);
				}
			}
		}
	} else {
		abort("Had all items. Why are you still doing this?");
	}
	return page;
}

void findTools(boolean side) {
	if(get_property("sidequestJunkyardCompleted")=="fratboy" || get_property("sidequestJunkyardCompleted")=="hippy") {
		print_quest_complete("Junkyard sidequest completed as "+get_property("sidequestJunkyardCompleted"));
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) warOutfit = "War Hippy Fatigue";
	set_backup_state();
	print_debug("Use outfit: " + warOutfit);
	outfit(warOutfit);
	visit_url("bigisland.php?action=junkman&pwd");
	get_backup_state();
	
	print_goal("Searching in the Junkyard.");
	custom_fight("haveAllTools","searchTools");
	
	outfit(warOutfit);
	visit_url("bigisland.php?action=junkman&pwd");
	get_backup_state();
}

boolean haveWarriorFratOutfit() {
	return have_outfit("Frat Warrior Fatigues") || is_wearing_outfit("Frat Warrior Fatigues");
}

boolean haveNormalHippyOutfit() {
	return have_outfit("Filthy Hippy Disguise") || is_wearing_outfit("Filthy Hippy Disguise");
}

boolean warStarted() {
	return contains_text(visit_url("island.php"),"A Conspicuous Absence of Pirate");
}

void StartWar() {
	if(contains_text(visit_url("questlog.php?which=1"),"see if you can't stir up some trouble")) {
		set_backup_state();
		if(!haveWarriorFratOutfit()) {
			if(pulls_remaining()>=3 && user_confirm("Do you wish to pull outfit and bypass this part?")) {
				if(!have_item($item[beer helmet])) take_storage(1,$item[beer helmet]);
				if(!have_item($item[distressed denim pants])) take_storage(1,$item[distressed denim pants]);
				if(!have_item($item[bejeweled pledge pin])) take_storage(1,$item[bejeweled pledge pin]);
			} else {
				if(!have_outfit("Filthy Hippy Disguise")) {
					print_goal("Searching for entry outfit.");
					obtain_outfit("Filthy Hippy Disguise",$location[Hippy Camp]);				
				}
				//fulfill_condition("haveNormalHippyOutfit",$location[Hippy Camp]);
				
				print_goal("Searching for frat warrior outfit.");
				outfit("Filthy Hippy Disguise");
				obtain_outfit("Frat Warrior Fatigues",$location[Wartime Frat House (Hippy Disguise)]);
				//fulfill_condition("haveWarriorFratOutfit",$location[Wartime Frat House (Hippy Disguise)]);
			}
		}
		outfit("Frat Warrior Fatigues");
		set_choices(142,3);
		set_choices(141,3);
		print_goal("Assassinating Franz Ferdinand.");
		fulfill_condition("warStarted",$location[Wartime Hippy Camp (Frat Disguise)]);
		print_debug("Rollback to checkpoint outfit.");
		get_backup_state();
	} else {
		print_quest_complete("War had started. By you. Congratulation, warmonger. Be proud of yourself.");
	}
}

void FightWar(boolean side) {
	if(!contains_text(visit_url("island.php"),"Conspicuous Absence")) {
		if(contains_text(visit_url("island.php"),"A Peaceful Meadow")) {
			print_quest_complete("The war had ended. One (or both) side has been destroyed. Good work, you.");
			return;
		} else {
			abort("War have not been started.");
		}
 	}
	council();
	if(side == side_hippy) {
		print_goal("End war as a hippy.");
		string warOutfit = "War Hippy Fatigue";
		abort("This part is not automated.");
	} else {
		print_goal("End war as a frat.");
		set_backup_state();
			print_debug("Flyering.");
			runFlyerDefault(side);
			print_debug("Search for Yossarian's tools.");
			findTools(side);
			print_debug("Search for bomb.");
			bombSearch(side);
		string warOutfit = "Frat Warrior Fatigue";
		print_debug("Use outfit: " + warOutfit);
		outfit(warOutfit);
		while(get_property("hippiesDefeated").to_int()<64) {
			while_abort();
			adventure(1,$location[The Battlefield (Frat Uniform)]);
		}
		get_backup_state();
			print_debug("Killing the filthworm queen.");
			dewormOrchard(side);
		outfit(warOutfit);
		while(get_property("hippiesDefeated").to_int()<1000) {
			while_abort();
			adventure(1,$location[The Battlefield (Frat Uniform)]);
		}
		print_goal("Finish the Big Whatever.");
		maximize_strength();
		outfit(warOutfit);
		visit_url("bigisland.php?action=bossfight&pwd");
		run_combat();
		get_backup_state();
	}
	council();
}

void main() {
	if(my_level() < 12){
		print_not_qualified("What do you mean by war?"); 
	} else {
		StartWar();
		FightWar(side_frat);
	}
}
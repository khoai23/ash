import <QuestLib.ash>;
import <zlib.ash>;
import <Spookyraven Upstairs.ash>;

int outfit_c;

boolean side_frat = true;
boolean side_hippy = false;

boolean checkBeePollen() {
	//set_transfer_value(!have_item($item[guy made of bee pollen]));
	return have_item($item[guy made of bee pollen]);
}

string beeKiller(boolean side) {
	string page = visit_url("adventure.php?snarfblat=392");
	if(contains_text(page,"Combat")) {
		if(contains_text(page,"Guy Made Of Bees")) {
			if(side==side_frat) {
				page=throw_items($item[rock band flyers],$item[antique hand mirror]);
			} else {
				page=throw_items($item[jam band flyers],$item[antique hand mirror]);
			}
		} else {
			page = run_combat();
		}
	} else {
		page = run_choice(page);
	}
	//checkBeePollen();
	return page;
}

void runFlyerDefault(boolean side) {
	if(get_property("sidequestArenaCompleted")=="fratboy" || get_property("sidequestArenaCompleted")=="hippy") {
		vprint("Arena sidequest completed as " + get_property("sidequestArenaCompleted"),"green",1);
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) {warOutfit = "War Hippy Fatigue"; outfit_c = 1; }
	cli_execute("checkpoint");
	print("Use outfit: " + warOutfit,"olive");
	outfit(warOutfit);
	visit_url("bigisland.php?place=concert");
	cli_execute("outfit checkpoint");
	
	int guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
	if(guyMadeOfBeesCount<4) {
		if(!user_confirm("You have only say TGMOB for " + guyMadeOfBeesCount + " times. Do you wish to find him anyway?")) {
			abort("Please do the flyer(ing) yourself.");
		}
	}
	
	if (!have_item($item[antique hand mirror]))	{
		set_bedroom_choices();
		obtain(1, "antique hand mirror", $location[the haunted bedroom]);
	}
	
	set_choices(105,3);
	custom_fight("checkBeePollen","beeKiller",side);
	/*
	while(!have_item($item[guy made of bee pollen])) {
		restore_hp(0);
		restore_mp(0);
		beeKiller(outfit);
		while_abort();
	}	
	*/
	
	outfit(warOutfit);
	visit_url("bigisland.php?place=concert");
	cli_execute("outfit checkpoint");
}

void dewormOrchard(boolean side) {
	if(get_property("sidequestOrchardCompleted")=="fratboy" || get_property("sidequestOrchardCompleted")=="hippy") {
		vprint("Orchard sidequest completed as "+get_property("sidequestOrchardCompleted"),"green",1);
		return;
	}
	// save current outfit for adventuring
	cli_execute("checkpoint");
	// determine outfit by which is available
	string war_outfit;
	if(side==side_hippy) war_outfit = "War Hippy Fatigue";
	else war_outfit = "Frat Warrior Fatigue";
	vprint("Using outfit " + war_outfit,"olive",1);
	
	// use outfit to receive quest
	outfit(war_outfit);
	visit_url("bigisland.php?place=orchard&action=stand&pwd");	
	outfit("checkpoint");
	
	vprint("Searching for scent gland...","blue",1);
	while (have_effect($effect[Filthworm Guard Stench]) == 0) {
      while (have_effect($effect[Filthworm Drone Stench]) == 0) {
         while (have_effect($effect[Filthworm Larva Stench]) == 0) {
            obtain(1, "filthworm hatchling scent gland", $location[the hatching chamber]);
            while_abort();
            if (!use(1, $item[filthworm hatchling scent gland])) vprint("You smell like a hatchling.","olive",4);
         }
		 vprint("Hatchling scent gland acquired.","blue",4);
         obtain(1, "filthworm drone scent gland", $location[the feeding chamber]);
         while_abort();
         if (!use(1, $item[filthworm drone scent gland])) vprint("You smell like a drone.","olive",4);
      }
	  vprint("Drone scent gland acquired.","blue",4);
      obtain(1, "filthworm royal guard scent gland", $location[the royal guard chamber]);
      while_abort();
      if (!use(1, $item[filthworm royal guard scent gland])) vprint("You smell like a guard.","olive",4);
   }
   vprint("Guard scent gland acquired.","blue",4);
   obtain(1, "heart of the filthworm queen", $location[the filthworm queen's chamber]);
   vprint("Filthworm heart acquired.","blue",2);
   
   outfit(war_outfit);
   // finish quest
   vprint("Deliver heart to owner...","blue",1);
   visit_url("bigisland.php?place=orchard&action=stand&pwd");	
   // receive meat
   visit_url("bigisland.php?place=orchard&action=stand&pwd");
   outfit("checkpoint");
}

void bombSearch(boolean side) {
	if(get_property("sidequestLighthouseCompleted")=="fratboy" || get_property("sidequestLighthouseCompleted")=="hippy") {
		vprint("Lighthouse sidequest completed as " + get_property("sidequestLighthouseCompleted"),"green",1);
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) warOutfit = "War Hippy Fatigue";
	cli_execute("checkpoint");
	outfit(warOutfit);
	vprint("Use outfit: " + warOutfit,"olive",5);
	vprint("Meet bombmaker...","blue",1);
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	vprint("Searching for bomb barrels...","blue",1);
	obtain(5, "barrel of gunpowder", $location[sonofa beach]);
	vprint("Deliver payload...","blue",1);
    visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	cli_execute("outfit checkpoint");
}

boolean haveAllTools() {
	return (have_item($item[molybdenum hammer]) && have_item($item[molybdenum crescent wrench]) &&
						have_item($item[molybdenum pliers]) && have_item($item[molybdenum screwdriver]));
}

string searchTools() {
	buffer page;
	if(!have_item($item[molybdenum hammer])) {
		page = visit_url("adventure.php?snarfblat=182");
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
		page = visit_url("adventure.php?snarfblat=184");
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
		page = visit_url("adventure.php?snarfblat=183");
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
		page = visit_url("adventure.php?snarfblat=185");
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
		vprint("Junkyard sidequest completed as "+get_property("sidequestJunkyardCompleted"),"green",1);
		return;
	}
	string warOutfit = "Frat Warrior Fatigue";
	if(side == side_hippy) warOutfit = "War Hippy Fatigue";
	cli_execute("checkpoint");
	vprint("Use outfit: " + warOutfit,"olive",5);
	outfit(warOutfit);
	visit_url("bigisland.php?action=junkman&pwd");
	cli_execute("outfit checkpoint");
	
	custom_fight("haveAllTools","searchTools");
	/*while(!have_item($item[molybdenum hammer]) || !have_item($item[molybdenum crescent wrench]) ||
		 !have_item($item[molybdenum pliers]) || !have_item($item[molybdenum screwdriver])) {
		while_abort();
		restore_hp(0);
		restore_mp(0);
		searchTools();
	}*/
	
	outfit(warOutfit);
	visit_url("bigisland.php?action=junkman&pwd");
	cli_execute("outfit checkpoint");
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
		cli_execute("checkpoint");
		if(!haveWarriorFratOutfit())
			if(pulls_remaining()>=3 && user_confirm("Do you wish to pull outfit and bypass this part?")) {
				if(!have_item($item[beer helmet])) take_storage(1,$item[beer helmet]);
				if(!have_item($item[distressed denim pants])) take_storage(1,$item[distressed denim pants]);
				if(!have_item($item[bejeweled pledge pin])) take_storage(1,$item[bejeweled pledge pin]);
			} else {
				vprint("Searching for entry outfit.","olive",5);
				fulfill_condition("haveNormalHippyOutfit",$location[Hippy Camp]);
				/*
				while(!haveNormalHippyOutfit()) {
					adventure(1,$location[Hippy Camp]);
					while_abort();
				}
				*/
				vprint("Searching for frat warrior outfit.","olive",5);
				outfit("Filthy Hippy Disguise");
				fulfill_condition("haveWarriorFratOutfit",$location[Wartime Frat House (Hippy Disguise)]);
				/*
				while(!have_outfit("Frat Warrior Fatigues") && !is_wearing_outfit("Frat Warrior Fatigues")) {
					adventure(1,$location[Wartime Frat House (Hippy Disguise)]);
					while_abort();
				}
				*/
			}
		outfit("Frat Warrior Fatigues");
		set_choices(142,3);
		set_choices(141,3);
		vprint("Assassinating Franz Ferdinand.","olive",5);
		fulfill_condition("warStarted",$location[Wartime Hippy Camp (Frat Disguise)]);
		/*
		while(!warStarted()) {
			adventure(1,$location[Wartime Hippy Camp (Frat Disguise)]);
			while_abort();
		}
		*/
		vprint("Rollback to checkpoint outfit.","olive",5);
		cli_execute("outfit checkpoint");
	} else {
		vprint("War had started. By you. Congratulation, warmonger. Be proud of yourself.","green",1);
	}
}

void FightWar(boolean side) {
	if(!contains_text(visit_url("island.php"),"Conspicuous Absence")) {
		if(contains_text(visit_url("island.php"),"A Peaceful Meadow")) {
			vprint("The war had ended. One (or both) side has been destroyed. Good work, you.","green",1);
			return;
		} else {
			abort("War have not been started.");
		}
 	}
	council();
	if(side == side_hippy) {
		vprint("End war as a hippy.","olive",5);
		string warOutfit = "War Hippy Fatigue";
		abort("This part is not automated.");
	} else {
		vprint("End war as a frat.","olive",5);
		cli_execute("checkpoint");
			vprint("Flyering.","olive",5);
			runFlyerDefault(side);
			vprint("Search for Yossarian's tools.","olive",5);
			findTools(side);
			vprint("Search for bomb.","olive",5);
			bombSearch(side);
		string warOutfit = "Frat Warrior Fatigue";
		vprint("Use outfit: " + warOutfit,"olive",5);
		outfit(warOutfit);
		while(get_property("hippiesDefeated").to_int()<64) {
			while_abort();
			adventure(1,$location[The Battlefield (Frat Uniform)]);
		}
		cli_execute("outfit checkpoint");
			vprint("Killing the filthworm queen.","olive",5);
			dewormOrchard(side);
		outfit(warOutfit);
		while(get_property("hippiesDefeated").to_int()<1000) {
			while_abort();
			adventure(1,$location[The Battlefield (Frat Uniform)]);
		}
		vprint("Finish the Big Whatever.","blue",1);
		visit_url("bigisland.php?action=bossfight&pwd");
		run_combat();
		cli_execute("outfit checkpoint");
	}
	council();
}

void main() {
	if(my_level() < 12){
		vprint("What do you mean by war?","green",1); 
	} else {
		StartWar();
		FightWar(side_frat);
	}
}
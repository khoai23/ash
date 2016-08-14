import <QuestLib.ash>;
import <keyFinder.ash>;
import <Level 10.ash>;

void confrontSorceress(boolean haveWand) {
	string macroId;
	if(!contains_text(my_name(),"khoai23")) abort("WHAM.ash currently can't handle the fight. Deal with her yourself."); 
	else {
		if(my_primestat()==$stat[mysticality]) 
			macroId = "122160"; // spellslinger
		else 
			macroId = "109152"; // physical
	}
	visit_url("place.php?whichplace=nstower&action=ns_10_sorcfight");
	use_macro(macroId);
	run_combat();
	waitq(1);
	visit_url("fight.php");
	use_macro(macroId);
	run_combat();
	waitq(1);
	string page=visit_url("fight.php");
	if(!contains_text(page,"You wake up in a heap")) {
		print_debug("Allow wand searching in cemetery.");
		visit_url("choice.php");
		manual_run_choice(1016,1);
	}
}

void wandFinder() {
	if(contains_text(visit_url("questlog.php?which=1"),"Frank thinks you can defeat the Sorceress using the wand of Nagamar")) {
		obtain_item(1,$item[Wand of Nagamar],$location[The VERY Unquiet Garves]);
		return;
	}
	if(have_item($item[disassembled clover]) || have_item($item[ten-leaf clover])) 
		if(user_confirm("Do you wish to clover the letters?")) {
			if(!have_item($item[ten-leaf clover])) use(1,$item[disassembled clover]);
			adv1($location[The Castle in the Clouds in the Sky (Basement)],-1,"");
			create(1,$item[Wand of Nagamar]);
			return;
		}
	if(!have_item($item[ruby W])) {
		obtain_item(1,$item[ruby W],$location[Pandamonium Slums]);
	}
	if(!have_item($item[metallic A])) {
		obtain_item(1,$item[metallic A],$location[The Penultimate Fantasy Airship]);
	}
	if(!have_item($item[ruby W])) {
		obtain_item(1,$item[lowercase N],$location[The Valley of Rof L'm Fao]);
	}
	if(!have_item($item[heavy D])) {
		obtain_item(1,$item[heavy D],$location[The Castle in the Clouds in the Sky (Basement)]);
	}
	create(1,$item[Wand of Nagamar]);
}

void shadowKilling() {
	set_backup_state();
	maximize_hp();
	if(my_maxhp()<250) abort("Your total health is too low to use this script.");
	if((!have_item($item[scented massage oil]) && !have_item($item[soggy used band-aid])) &&
	   (item_amount($item[scented massage oil])+item_amount($item[soggy used band-aid])<2 && my_maxhp()<400) &&
	   (item_amount($item[gauze garter])*90+item_amount($item[filthy poultice])*90+item_amount($item[red pixel potion])*100<400)) 
	     abort("You don't have enough healing item to automate.");
		 
	int max_shadow_attack = my_maxhp()/6+100;
	if(my_hp()<max_shadow_attack) abort("You will probably get one-shotted. Raise your hp above "+max_shadow_attack+" to try.");
	string page = visit_url("place.php?whichplace=nstower&action=ns_09_monster5");
	item heal_choice;
	while(!contains_text(page,"shadow version of yourself explodes") && !contains_text(page,"You slink away, dejected and defeated.")) {
		if(have_item($item[scented massage oil]) || have_item($item[soggy used band-aid])) {
			if(have_item($item[scented massage oil])) heal_choice = $item[scented massage oil];
			else heal_choice = $item[soggy used band-aid];
			if(my_hp()<max_shadow_attack) { 
				print_combat_info("Heal now for maximum effect.");
				page=throw_item(heal_choice);
			} else {
				print_combat_info("Wait for lower health.");
				page=throw_item($item[spectre scepter]);
			}
		} else {
			if(have_item($item[red pixel potion])) heal_choice = $item[red pixel potion];
			else if(have_item($item[gauze garter])) heal_choice = $item[gauze garter];
			else heal_choice = $item[filthy poultice];
			if(my_maxhp()-my_hp() > 240 && have_skill($skill[Ambidextrous Funkslinging])) {
				print_combat_info("Funkslinging items.");
				if(item_amount(heal_choice)>=2) page=throw_items(heal_choice,heal_choice);
				else {
					item second_heal_choice;
					if(have_item($item[filthy poultice])) second_heal_choice = $item[filthy poultice];
					else second_heal_choice = $item[gauze garter];
					page=throw_items(heal_choice,second_heal_choice);
				}
			} else if(my_maxhp() - my_hp() > 120) {
				print_combat_info("Use single item.");
				page=throw_item(heal_choice);
			} else {
				print_combat_info("Wait for lower health.");
				page=throw_item($item[spectre scepter]);
			}
		}
	}
	get_backup_state();
}

void NaughtyQuest() {
	if(my_level() >= 13) {
        council();

		string page;
		if (contains_text(visit_url("questlog.php?which=1"),"The Ultimate Final Epic Conflict of the Ages")) {
			set_backup_state();
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_regdesk.gif")) {
				print_goal("Register every contest available.");
				page = visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
				if(contains_text(page,"Enter the Fastest Adventurer contest")) {
					page = manual_run_choice(1003,1);
				}
				if(contains_text(page,"Enter the Strongest Adventurer contest")
				   || contains_text(page,"Enter the Smartest Adventurer contest")
				   || contains_text(page,"Enter the Smoothest Adventurer contest") ) {
					page = manual_run_choice(1003,2);
				}
				if(contains_text(page,"Enter the Hottest Adventurer contest")
				   || contains_text(page,"Enter the Sleaziest Adventurer contest")
				   || contains_text(page,"Enter the Spookiest Adventurer contest")
				   || contains_text(page,"Enter the Coldest Adventurer contest")
				   || contains_text(page,"Enter the Stinkiest Adventurer contest") ) {
					page = manual_run_choice(1003,3);
				}
				page = manual_run_choice(1003,6);
				print_goal_complete("Done registering.");
				
				print_goal("Rid this world of pesky contestants!");
				while(contains_text(visit_url("place.php?whichplace=nstower"),"crowd1.gif")) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					visit_url("place.php?whichplace=nstower&action=ns_01_crowd1");
					run_combat();
				}
				while(contains_text(visit_url("place.php?whichplace=nstower"),"crowd2.gif")) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					visit_url("place.php?whichplace=nstower&action=ns_01_crowd2");
					run_combat();
				}
				while(contains_text(visit_url("place.php?whichplace=nstower"),"crowd3.gif")) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					visit_url("place.php?whichplace=nstower&action=ns_01_crowd3");
					run_combat();
				}
				
				print_goal("Claim your righteous prize.");
				visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
				page = manual_run_choice(1003,4);
			} else {
				print_goal_complete("Dealed with the contest.");
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_courtyard.gif")) {
				visit_url("place.php?whichplace=nstower&action=ns_02_coronation");
				manual_run_choice(1020,1);
				manual_run_choice(1021,1);
				manual_run_choice(1022,1);
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_hedgemaze.gif")) {
				page = visit_url("place.php?whichplace=nstower&action=ns_03_hedgemaze");
				run_choice(page);
			} else {
				print_goal_complete("Passed the hedge.");
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_towerdoor.gif")) {
				print_goal("Open locks on the door.");
				page = visit_url("place.php?whichplace=nstower_door");
				if(contains_text(page,"lock_boris.gif")) {
					borisKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock1");
				}
				if(contains_text(page,"lock_jarlsberg.gif")) {
					jarlsbergKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock2");
				}
				if(contains_text(page,"lock_pete.gif")) {
					sneakyPeteKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock3");
				}
				if(contains_text(page,"lock_star.gif")) {
					starKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock4");
				}
				if(contains_text(page,"lock_digital.gif")) {
					digitalKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock5");
				}
				if(contains_text(page,"lock_skeleton.gif")) {
					skeletonKey();
					visit_url("place.php?whichplace=nstower_door&action=ns_lock6");
				}
				visit_url("place.php?whichplace=nstower_door&action=ns_doorknob");
			}  else {
				print_goal_complete("Opened the damned door.");
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower1.gif")) {
				while_abort();
				restore_hp(0);
				restore_mp(0);
				visit_url("place.php?whichplace=nstower&action=ns_05_monster1");
				throw_item($item[beehive]);
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower2.gif")) {
				set_backup_state();
				maximize_meat();
				while(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower2.gif")) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					visit_url("place.php?whichplace=nstower&action=ns_06_monster2");
					run_combat();
				}				
				get_backup_state();
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower3.gif")) {
				if(!have_item($item[electric boning knife])) {
					find_boneKnife();
				}
				while_abort();
				restore_hp(0);
				restore_mp(0);
				visit_url("place.php?whichplace=nstower&action=ns_07_monster3");
				throw_item($item[electric boning knife]);
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower4.gif")) {
				visit_url("place.php?whichplace=nstower&action=ns_08_monster4");
				manual_run_choice(1015,2);
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"nstower_tower5.gif")) {
				shadowKilling();
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"chamberlabel.gif")) {
				if(!have_item($item[Wand of Nagamar]) && user_confirm("Do you wish to find the wand before attacking the Sorceress?")) {
					wandFinder();
				}
				
				if(!have_item($item[Wand of Nagamar])) {
					print_minor_warning("Prepare to get beaten up. You choose it yourself.");
					confrontSorceress(false);
					wandFinder();
				}
				confrontSorceress(true);
			}
			
			if(contains_text(visit_url("place.php?whichplace=nstower"),"kingprismanim.gif")) {
				visit_url("place.php?whichplace=nstower&action=ns_11_prism");
			}
		} else if (contains_text(visit_url("questlog.php?which=2"),"The Ultimate Final Epic Conflict of the Ages")) {
			print_quest_complete("You have already completed the level 13 quest.");
		} else {
			print_not_qualified("The level 13 quest is not currently available. You may have not completed all the other quests.");
		}
	} else {
		print_not_qualified("You must be at least level 13 to attempt this quest.");
	}
}
void main()
{
	NaughtyQuest();
}

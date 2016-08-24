script "Misc.ash";
import <QuestLib.ash>;

void setAdventure() {
	if(!have_item($item[old claw-foot bathtub])) set_choices(794,1);
	else if(!have_item($item[old clothesline pole])) set_choices(794,2);
	else set_choices(794,3);
}

boolean haveComponent() {
	return have_item($item[old claw-foot bathtub]) && have_item($item[old clothesline pole]) && have_item($item[antique cigar sign]);
}

record ghost_babies {
	string in_room;
	string hate;
	string enter;
	string love;
};

// CONST for searching
ghost_babies [int] babies;
babies[0].hate = "The giggling ghost stops giggling and starts scowling";
babies[0].enter = "The giggling ghost, excited by the toy";
babies[0].love = "The giggling ghost squeals with delight";
babies[0].in_room = "The giggling ghost is here";
babies[1].hate = "The weeping ghost begins crying even louder";
babies[1].enter = "The weeping ghost enters the room";
babies[1].love = "The weeping ghost stops crying for a moment";
babies[1].in_room = "The weeping ghost is here";
babies[2].hate = "The chubby ghost frowns and storms out of the room";
babies[2].enter = "The chubby ghost enters the room";
babies[2].love = "The chubby ghost is momentarily enthralled";
babies[2].in_room = "The chubby ghost is here";

// You only need to adventure at storage for one enter and two hate
// the string will store (choiceAdv)|(questProgress)|choiceX_hate|choiceX_enter
string runBabiesSearch() {
	string page = visit_url(to_url($location[The Haunted Storage Room]));
	
	if(contains_text(page,"Combat")) {
		page = run_combat();
	} else if(contains_text(page,"Chasin' Babies")) {
		string result;
		if(get_property("spookyravenBabies").char_at(0).to_int()<2) {
			print_debug("Parsing data, initializing.");
			page = manual_run_choice(886,get_property("spookyravenBabies").char_at(0).to_int()+1);
			string result_hate = "|";
			string result_love = "|";
			int count = get_property("spookyravenBabies").char_at(2).to_int();
			for i from 0 upto 2 {			
				if(contains_text(page,babies[i].hate)) {
					result_hate = result_hate + to_string(i);
					count += 1;
				}
				if(contains_text(page,babies[i].enter)) {
					result_love = result_love + to_string(i);
					count += 4;
				}
				if(contains_text(page,babies[i].love)) {
					result_love = result_love + to_string(i);
				}
			}
			result = get_property("spookyravenBabies")+result_hate+result_love;
			result = to_string(result.char_at(0).to_int()+1)+ "|"+to_string(count)+substring(result,3);
			print_debug("New string crafted : " + result);
			set_property("spookyravenBabies",result);
		} else if(get_property("spookyravenBabies").char_at(0).to_int()==2) {
			print_debug("Have data, parse choice after these.");
			int ghost_count = 0;
			for i from 0 upto 2 {
				if(contains_text(page,babies[i].in_room)) ghost_count +=1;
			}
			string choice;
			if(ghost_count==0) {
				print_debug("No ghost, checking for choice sequence.");
				// choice 3 will inevitably rope the last one in, so the other choice that did not do anything will expel it
				// if choice 1 is hated by the old one, choice 2 will be hated by the last one, and vice versa
				choice = "3";
				if(get_property("spookyravenBabies").char_at(4)=="|") choice = choice + "1";
				else choice = choice + "2";
				print_debug("Choice sequence: " + choice);
			} else if(ghost_count==1) {
				print_debug("One ghost, checking for originalty.");
				if(get_property("spookyravenBabies").char_at(2)=="0") {
					// Old one, so choice 3 will expel it and rope the last one in. Likewise, the choice that do nothing will expel it
					// There is no hate involved, so we can go to char 5 and check
					choice = "3";
					if(get_property("spookyravenBabies").char_at(5)=="|") choice = choice + "1";
					else choice = choice + "2";
				} else {
					// New one, so one choice should have expelled the old one.
					// whatever happened, the next choice would expel the new one anyway
					choice = "3";
				}
				print_debug("Choice sequence: " + choice);
			} else if(ghost_count==2) {
				print_debug("Two ghost, no checking neccessary");
				// Both ghost are in, which mean 1st choice can clear the new one.
				// 1-new in, 2-new out cant work, so it must be 1-new out,2-new in 
				choice = "31";
				print_debug("Choice sequence: " + choice);
			} else {
				abort("This is not supposed to be reached.");
			}
			
			if(length(choice)==1){
				page = manual_run_choice(886,to_int(choice));
			}
			else {
				page = manual_run_choice(886,to_int(choice.char_at(0)));
				result = result + choice.char_at(1);
			}
			// Parse to continue quest
			int count = get_property("spookyravenBabies").char_at(2).to_int();
			for i from 0 upto 2 {			
				if(contains_text(page,babies[i].hate)) {
					count += 1;
				}
				if(contains_text(page,babies[i].enter)) {
					count += 4;
				}
			}
			result = get_property("spookyravenBabies");
			result = to_string(result.char_at(0).to_int()+1)+ "|"+to_string(count)+substring(result,3);
			set_property("spookyravenBabies",result);
		} else if(get_property("spookyravenBabies").char_at(0).to_int()==3) {
			result = get_property("spookyravenBabies");
			print_debug("Finalize the choice, string: " + result);
			page = manual_run_choice(886,to_int(result.char_at(length(result)-1)));
			int count = get_property("spookyravenBabies").char_at(2).to_int();
			for i from 0 upto 2 {			
				if(contains_text(page,babies[i].hate)) {
					count += 1;
				}
				if(contains_text(page,babies[i].enter)) {
					count += 4;
				}
			}
			result = to_string(result.char_at(0).to_int()+1)+ "|"+to_string(count) + substring(result,3);
			set_property("spookyravenBabies",result);
		} else {
			abort("Error during script execution. Leaving.");
		}
	} else {
		page = run_choice(page);
	}
	return page;
}

boolean checkTopFloorProgress() {
	return get_property("spookyravenBabies").char_at(2)=="6";
}

void SpookyravenTopFloor() {
	if(contains_text(visit_url("questlog.php?which=2"),"Lady Spookyraven's Babies")) {
		print_quest_complete("You have taken the babies ghost to their mother ghost. Why, though?");
		return;
	} else if (!contains_text(visit_url("questlog.php?which=1"),"Lady Spookyraven's Babies")) {
		if(!contains_text(visit_url("place.php?whichplace=manor2"),"place.php?whichplace=manor3")) {
			print_not_qualified("You have not yet reached the third floor.");
			return;
		}
		print_debug("Quest not started.");
		visit_url("place.php?whichplace=manor3&action=manor3_ladys");
		set_property("spookyravenBabies","0|0");
	}
	if(!have_item($item[jar of baby ghosts])) {
		if(get_property("spookyravenBabies")!="0|0") 
			if(user_confirm("The quest pointer is not default. If you have not run this quest this ascension, press yes. Otherwise press no.")) {
				print_debug("Reset pointer to 0,0");
				set_property("spookyravenBabies","0|0");
			}
		set_backup_state();
		custom_fight("checkTopFloorProgress","runBabiesSearch");

		set_choices(884,4);
		obtain_item(1,$item[jar of baby ghosts],$location[The Haunted Laboratory]);
	}
	visit_url("place.php?whichplace=manor3&action=manor3_ladys");
}

void JunkShipQuest() {
	if(contains_text(visit_url("woods.php"),"smokesignals.gif")) {
		print_goal("Talk to the stranded hippy.");
		visit_url("place.php?whichplace=woods&action=woods_smokesignals");
		visit_url("choice.php?pwd&whichchoice=798&option=1");
		visit_url("choice.php?pwd&whichchoice=798&option=2");
	}
	if(contains_text(visit_url("questlog.php?which=1"),"Give a Hippy a Boat")) {
		
		set_choices(795,1);
		set_choices(796,2);
		set_choices(797,3);
		set_backup_state();
		setAdventure();
		fulfill_condition("haveComponent","setAdventure",$location[The Old Landfill]);
		create(1,$item[junk junk]);
		print_goal("Bringing the boat to the hippy.");
		visit_url("place.php?whichplace=woods&action=woods_hippy");
	} else if(contains_text(visit_url("questlog.php?which=2"),"Give a Hippy a Boat")) {
		print_quest_complete("You have already gave a boat to a stranded hippy. Which you take back anyway.");
	} else {
		print_not_qualified("You can't do the quest.");
	}
}

void main() {
	if(my_level()>4 && !contains_text(visit_url("main.php"),"island.gif")
		&& user_confirm("Do you wish to open the island?"))
		JunkShipQuest();
	if(my_level()>6 && contains_text(visit_url("place.php?whichplace=manor3"),"sr_ladys.gif")
		&& user_confirm("Do you wish to do the top floor quest?"))
		SpookyravenTopFloor();
}
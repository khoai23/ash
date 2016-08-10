import <QuestLib.ash>;
import <zlib.ash>;

void set_pirate_choices() {
	// Test of tsterone
	if(my_primestat()==$stat[mysticality]) set_choices(186,1);
	else set_choices(186,3);
	// Explain the eyepatches
	if(my_primestat()==$stat[mysticality])
		set_choices(184,2);
	else set_choices(184,1);
	// Rock star
	if(my_inebriety()==0) set_choices(185,3);
	else set_choices(185,2);
	
}

int insult_count()
{
	int totalInsults = 0;
	for i from 1 upto 8
	{
		if (to_boolean(get_property("lastPirateInsult" + to_string(i))))
		{
			totalInsults = totalInsults + 1;
		}
	}

	return totalInsults;

}

string beer_pong(string page)
{
	record r
	{
		string insult;
		string retort;
	};

	r [int] insults;

	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";

	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";

	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";

	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";

	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";

	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";

	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";

	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while (!page.contains_text("victory laps"))
	{
		string old_page = page;

		if (!page.contains_text("Insult Beer Pong"))
		{
			abort("You don't seem to be playing Insult Beer Pong.");			
		}

		if (page.contains_text("Phooey"))
		{
			print_minor_warning("Looks like something went wrong and you lost.");
			return page;
		}
	
		foreach i in insults
		{
			if (page.contains_text(insults[i].insult))
			{
				if (page.contains_text(insults[i].retort)) {
					print_goal_complete("Found appropriate retort for insult.");
					print_debug("Insult: " + insults[i].insult);
					print_debug("Retort: " + insults[i].retort);
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;			
				} else {
					print_not_qualified("Looks like you needed a retort you haven't learned.");
					print_debug("Insult: " + insults[i].insult);
					print_debug("Retort: " + insults[i].retort);
	
					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if (page == old_page)
		{
			abort("String not found. There may be an error with one of the insult or retort strings.");
		}
	}

	vprint("You won a thrilling game of Insult Beer Pong!", "green",1);
	return page;
}

string pirate_fight(boolean insult) {	
	if(insult) {
		if (!have_item($item[The Big Book of Pirate Insults])) {
			buy(1, $item[The Big Book of Pirate Insults]);
		}
		if (!have_item($item[The Big Book of Pirate Insults])) {
			abort("Couldn't buy The Big Book of Pirate Insults");
		}
	}

	string page = visit_url("adventure.php?snarfblat=157");
	
	if (contains_text(page, "Combat"))
	{
		// trusting WHAM for this part
		page = run_combat();

		print_debug("You have learned " + to_string(insult_count()) + "/8 pirate insults.");
	}
	else if (contains_text(page, "Arrr You Man Enough?"))
	{
		int totalInsults = insult_count();
		if (totalInsults > 6){
			print_debug("You have learned " + to_string(totalInsults) + "/8 pirate insults.");
			page = beer_pong( visit_url( "choice.php?pwd&whichchoice=187&option=1" ) );
		} else {
			print_debug("You have learned " + to_string(totalInsults) + "/8 pirate insults.");
			print_debug("Search for more insult..");
			page = visit_url("choice.php?pwd&whichchoice=187&option=2" );
		}
	} else if (contains_text(page, "Arrr You Man Enough?")) {
		page = beer_pong(page);
	} else {
		page = run_choice(page);
	}

	return page;
}

boolean haveBootyMap() {
	return have_item($item[Cap'm Caronch's Map]);
}

boolean readyToBeerPong() {
	return have_item($item[Orcish Frat House blueprints]) && (insult_count()>=6);
}

boolean haveAccessToDeck() {
	return contains_text(visit_url("cove.php"),"The F'c'le");
}

boolean haveFledge() {
	return have_item($item[pirate fledges]);
}

void useTools() {
	if (have_item($item[mizzenmast mop])) {
		use(1, $item[mizzenmast mop]);
	}
	if (have_item($item[ball polish])) {
		use(1, $item[ball polish]);
	}
	if (have_item($item[rigging shampoo])) {
		use(1, $item[rigging shampoo]);
	}
}

void PirateQuest()
{
	set_pirate_choices();

	if (!have_item($item[pirate fledges]) && equipped_amount($item[pirate fledges])==0)
	{
		if (!have_outfit("swashbuckling getup")) {
			set_backup_state();
			if(pulls_remaining()>=4 && user_confirm("Would you like to pull the getup+book?")) {
				take_storage(1,$item[eyepatch]);
				take_storage(1,$item[stuffed shoulder parrot]);
				take_storage(1,$item[swashbuckling pants]);
				take_storage(1,$item[The Big Book of Pirate Insults]);
			} else if(user_confirm("Would you like to adventure for the swashbuckling getup?")) {		
				obtain_outfit("swashbuckling getup",$location[The Obligatory Pirate's Cove]);
			} else {
				abort("You do it yourself, fag.");
			}
			get_backup_state();
		}

		if (!contains_text(visit_url("questlog.php?which=1"),"I Rate, You Rate")) {
			set_backup_state();
			outfit("swashbuckling getup");
	
			if(!haveBootyMap()) {
				print_goal("Meet the Cap' and get map.");
				custom_fight("haveBootyMap","pirate_fight",true);
				//fulfill_condition("haveBootyMap",$location[Barrrney's Barrr]);
			}
	
			get_backup_state();
		}

		if (contains_text(visit_url("questlog.php?which=1"),
		"A salty old pirate named Cap'm Caronch has offered to let you join his crew if you find some treasure for him.")){
			if (have_item($item[Cap'm Caronch's Map])) {
				print_goal("Use map and kill crab.");
				while_abort();
				use(1, $item[Cap'm Caronch's Map]);
				run_combat();
			}
		}

		if (insult_count()<6 || contains_text(visit_url("questlog.php?which=1"),
		"Now that you've found Cap'm Caronch's booty (and shaken it a few times), you should probably take it back to him.")){
			set_backup_state();
			outfit("swashbuckling getup");
			if(!readyToBeerPong()) {
				print_goal("Searching for Frat House blueprints and appropriate amount of insult mastery.");
				custom_fight("readyToBeerPong","pirate_fight",true);
			}
			
			get_backup_state();
		}

		if (contains_text(visit_url("questlog.php?which=1"),
		"Cap'm Caronch has given you a set of blueprints to the Orcish Frat House, and asked you to steal his dentures back from the Frat Orcs.")) {
			if (have_item($item[Orcish Frat House blueprints])) {
				while_abort();
				set_backup_state();
				if (!have_item($item[Cap'm Caronch's dentures])) {
					if ((!have_item($item[frilly skirt])) && (item_amount($item[hot wing]) >= 3)) {
						print_goal("Obtain frilly skirt.");
						if (knoll_available()) {
							buy(1, $item[frilly skirt]);
						} else if(user_confirm("Do you want to search for a frilly skirt?")) {
							obtain(1,$item[frilly skirt],$location[The Degrassi Knoll Gym]);
						} else {
							print_minor_warning("Not getting a frilly skirt");
						}
					}
	
					if (have_item($item[frilly skirt]) && (item_amount($item[hot wing]) >= 3)) {
						print_goal("Catburgle");
						equip($item[frilly skirt]);
						set_choices(188,3);
						use(1, $item[Orcish Frat House blueprints]);
						get_backup_state();
					}
				}

				if (!have_item($item[Cap'm Caronch's dentures])) {
					if (have_item($item[mullet wig]) && have_item($item[briefcase])) {
						print_goal("Salesman disguise.");
						equip($item[mullet wig]);
						set_choices(188,2);
						use(1, $item[Orcish Frat House blueprints]);
						get_backup_state();
					}
				}

				if (!have_item($item[Cap'm Caronch's dentures])) {
					if ((!have_outfit("Frat Boy Ensemble")) &&
						 user_confirm("Would you like to adventure for the Frat Boy Ensemble?")) {
						print_goal("Obtain frat outfit.");
						obtain_outfit("Frat Boy Ensemble", $location[Frat House]);
					}
	
					if (have_outfit("Frat Boy Ensemble") || is_wearing_outfit("Frat Boy Ensemble")) {
						outfit("Frat Boy Ensemble");
						print_goal("Infiltrate");
						set_choices(188,1);
						use(1, $item[Orcish Frat House blueprints]);
						get_backup_state();
					}
				}
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),
		"You have successfully swiped the Cap'm's teeth from the Frat Orcs -- time to take the nasty things back to him.")) {
			set_backup_state();
			outfit("swashbuckling getup");
			print_goal("Meet the Cap' and initialize Beer Pong.");
			while (available_amount($item[Cap'm Caronch's dentures]) > 0) {
				while_abort();
				restore_hp(0);
				restore_mp(0);
				pirate_fight(true);
			}
			get_backup_state();
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You've completed two of Cap'm Caronch's tasks, but (surprise surprise) he's got a third one for you before you can join his crew.")){
			set_backup_state();
			outfit("swashbuckling getup");
			print_goal("Met the captain one more time");
			custom_fight("haveAccessToDeck","pirate_fight",false);
			get_backup_state();
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You have successfully joined Cap'm Caronch's crew!")) {
			set_backup_state();
			outfit("swashbuckling getup");
			print_goal("Do your chores.");
			fulfill_condition("haveFledge","useTools",$location[The F'c'le]);
			get_backup_state();
		}
	} else {
		print_quest_complete("You have already have the pirate fledges.");
	}
	
}

void main()
{
	PirateQuest();
}
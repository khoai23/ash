import <QuestLib.ash>;
import <zlib.ash>;

void set_pirate_choices() {
	// Test of tsterone
	if(my_primestat()==$stat[mysticality]) set_choices(186,1);
	else set_choices(186,3);
	// Explain the eyepatches
	set_choices(184,6);
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
			vprint("Looks like something went wrong and you lost.", "red",2);
			return page;
		}
	
		foreach i in insults
		{
			if (page.contains_text(insults[i].insult))
			{
				if (page.contains_text(insults[i].retort))
				{
					vprint("Found appropriate retort for insult.", "green",1);
					vprint("Insult: " + insults[i].insult,"black",5);
					vprint("Retort: " + insults[i].retort,"black",5);
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;			
				}
				else
				{
					vprint("Looks like you needed a retort you haven't learned.", "red",1);
					vprint("Insult: " + insults[i].insult,"red",5);
					vprint("Retort: " + insults[i].retort,"black",5);
	
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

string pirate_fight(boolean insult)
{	
	if(insult) {
		if (available_amount($item[The Big Book of Pirate Insults]) == 0)
		{
			buy(1, $item[The Big Book of Pirate Insults]);
		}
		if (available_amount($item[The Big Book of Pirate Insults]) == 0)
		{
			abort("Couldn't buy The Big Book of Pirate Insults");
		}
	}

	string page = visit_url("adventure.php?snarfblat=157");
	
	if (contains_text(page, "Combat"))
	{
		// trusting WHAM for this part
		page = run_combat();

		vprint("You have learned " + to_string(insult_count()) + "/8 pirate insults.", "blue",5);
	}
	else if (contains_text(page, "Arrr You Man Enough?"))
	{
		int totalInsults = insult_count();
		if (totalInsults > 6)
		{
			vprint("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue",5);
			page = beer_pong( visit_url( "choice.php?pwd&whichchoice=187&option=1" ) );
		}
		else
		{
			vprint("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue",5);
			vprint("Searching for more insult..", "blue",1);
			page = visit_url( "choice.php?pwd&whichchoice=187&option=2" );
		}
	}
	else if (contains_text(page, "Arrr You Man Enough?"))
	{
		page = beer_pong(page);
	}
	else
	{
		page = run_choice(page);
	}

	return page;
}

void PirateQuest()
{
	set_pirate_choices();

	if (!have_item($item[pirate fledges]) && equipped_amount($item[pirate fledges])==0)
	{
		if (!have_outfit("swashbuckling getup")) {
			if(pulls_remaining()>=4 && user_confirm("Would you like to pull the getup+book?")) {
				take_storage(1,$item[eyepatch]);
				take_storage(1,$item[stuffed shoulder parrot]);
				take_storage(1,$item[swashbuckling pants]);
				take_storage(1,$item[The Big Book of Pirate Insults]);
			} else if(user_confirm("Would you like to adventure for the swashbuckling getup?")) {				
				while(!have_outfit("swashbuckling getup")){
					while_abort();
					adventure(1,$location[The Obligatory Pirate's Cove]);
				}
			} else {
				abort("You do it yourself, fag.");
			}
		}

		if (!contains_text(visit_url("questlog.php?which=1"),"I Rate, You Rate"))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
	
			while (available_amount($item[Cap'm Caronch's Map]) == 0)
			{
				vprint("Searching for Cap Caronch Map","olive",5);
				restore_hp(0);
				restore_mp(0);
				pirate_fight(true);
				while_abort();
			}
	
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"A salty old pirate named Cap'm Caronch has offered to let you join his crew if you find some treasure for him."))
		{
			if (have_item($item[Cap'm Caronch's Map]))
			{
				vprint("Using Cap Caronch Map","olive",5);
				while_abort();
				use(1, $item[Cap'm Caronch's Map]);
				run_combat();
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),"Now that you've found Cap'm Caronch's booty (and shaken it a few times), you should probably take it back to him."))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
	
			while (!have_item($item[Orcish Frat House blueprints]))
			{
				vprint("Searching for Frat House blueprints","olive",5);
				while_abort();
				restore_hp(0);
				restore_mp(0);
				pirate_fight(true);
			}
	
			cli_execute("outfit checkpoint");
		}

		// Get the insults before using the frat house map
		if (insult_count() <= 6)
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");

			while (insult_count() <= 6)
			{
				vprint("Searching for 6/8 insult (best balance)","olive",5);
				while_abort();
				restore_hp(0);
				restore_mp(0);
				pirate_fight(true);
			}

			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"Cap'm Caronch has given you a set of blueprints to the Orcish Frat House, and asked you to steal his dentures back from the Frat Orcs."))
		{
			if (have_item($item[Orcish Frat House blueprints]))
			{
				while_abort();
				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					if ((available_amount($item[frilly skirt]) == 0) && (available_amount($item[hot wing]) >= 3))
					{
						vprint("Obtain frilly skirt","olive",5);
						if (knoll_available())
						{
							buy(1, $item[frilly skirt]);
						} else if(user_confirm("Do you want to search for a frilly skirt?")) {
							cli_execute("conditions clear");
							add_item_condition(1,$item[frilly skirt]);
							adventure(my_adventures(),$location[The Degrassi Knoll Gym]);
						} else {
							vprint("Not getting a frilly skirt","red",1);
						}
					}
	
					if ((available_amount($item[frilly skirt]) > 0) && (available_amount($item[hot wing]) >= 3))
					{
						vprint("Catburgling","olive",5);
						cli_execute("checkpoint");
						equip($item[frilly skirt]);
						set_choices(188,3);
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}

				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					if ((available_amount($item[mullet wig]) > 0) && (available_amount($item[briefcase]) > 1))
					{
						vprint("Using mullet wig","olive",5);
						cli_execute("checkpoint");
						equip($item[mullet wig]);
						set_choices(188,2);
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}

				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					if ((!have_outfit("Frat Boy Ensemble")) &&
						(user_confirm("Would you like to adventure for the Frat Boy Ensemble?")))
					{
						vprint("Obtain frat outfit","olive",5);
						cli_execute("conditions clear");
						set_location($location[Frat House]);
						cli_execute("conditions add outfit");
						adventure(my_adventures(), $location[Frat House]);
					}
	
					if (have_outfit("Frat Boy Ensemble"))
					{
						vprint("Using frat outfit","olive",5);
						cli_execute("checkpoint");
						outfit("Frat Boy Ensemble");
						set_choices(188,1);
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You have successfully swiped the Cap'm's teeth from the Frat Orcs -- time to take the nasty things back to him."))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
			while (available_amount($item[Cap'm Caronch's dentures]) > 0)
			{
				while_abort();
				restore_hp(0);
				restore_mp(0);
				pirate_fight(true);
			}
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You've completed two of Cap'm Caronch's tasks, but (surprise surprise) he's got a third one for you before you can join his crew."))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
			while (!contains_text(visit_url("cove.php"),"The The F'c'le"))
			{
				while_abort();
				restore_hp(0);
				restore_mp(0);
				pirate_fight(false);
			}
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You have successfully joined Cap'm Caronch's crew!"))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");

			while (available_amount($item[pirate fledges]) == 0)
			{
				while_abort();
				adventure(1, $location[The F'c'le]);

				if (available_amount($item[mizzenmast mop]) > 0)
				{
					use(1, $item[mizzenmast mop]);
				}
				if (available_amount($item[ball polish]) > 0)
				{
					use(1, $item[ball polish]);
				}
				if (available_amount($item[rigging shampoo]) > 0)
				{
					use(1, $item[rigging shampoo]);
				}
			}

			cli_execute("outfit checkpoint");
		}
	}
	else
	{
		print("You have already have the pirate fledges.");
	}
}

void main()
{
	PirateQuest();
}

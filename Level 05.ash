import <QuestLib.ash>;
import <zlib.ash>;

boolean haveHaremOutfit() {
	return have_outfit("knob goblin harem girl disguise") || is_wearing_outfit("knob goblin harem girl disguise");
}

void GoblinQuest()
{
	if (my_level() >= 5)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"The Goblin Who Wouldn't Be King"))
		{
			if (!contains_text(visit_url("plains.php"),"knob2.gif"))
			{
				if (!have_item($item[Knob Goblin encryption key]))
				{
					print_goal("Search for encryption key");
					obtain(1, $item[Knob Goblin encryption key], $location[The Outskirts of Cobb's Knob]);
				}
				use(1, $item[Cobb's Knob map]);
			}
			else
			{
				print_quest_complete("Cobb's Knob is already available.");
			}

			if(!haveHaremOutfit()) {
				fulfill_condition("haveHaremOutfit",$location[Cobb's Knob Harem]);
			}
	
			if(haveHaremOutfit())
			{
				if (user_confirm("Try for the Glass Balls of the Goblin King?"))
				{
					update_mcd(3);
				}
				else if (user_confirm("Try for the Cape of the Goblin King?"))
				{
					update_mcd(7);
				}
				else if ((in_mysticality_sign()) && (!contains_text(visit_url("trophies.php"),"Boss Boss")))
				{
					if (user_confirm("Try for the Boss Boss trophy?"))
					{
						update_mcd(11);      
					}
				}
	
				cli_execute("checkpoint");
				while_abort();
				outfit("Knob Goblin Harem Girl Disguise");
				if(have_item($item[knob goblin perfume])) {
					use(1,$item[knob goblin perfume]);
				} else {
					vprint("Lose an adventure for perfume","olive",5);
					adventure(1,$location[Cobb's Knob Harem]);
				}  
				adventure(1, $location[Throne Room]);
				cli_execute("outfit checkpoint");
			}
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Goblin Who Wouldn't Be King"))
		{
			print_quest_complete("You have already completed the level 5 quest.");
		}
		else
		{
			print_warning("The level 5 quest is not currently available.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 5 to attempt this quest.");
	}
}

void main()
{
	GoblinQuest();
}

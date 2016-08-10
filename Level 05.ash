import <QuestLib.ash>;
import <zlib.ash>;

boolean haveHaremOutfit() {
	return have_outfit("Knob Goblin Harem Girl Disguise") || is_wearing_outfit("Knob Goblin Harem Girl Disguise");
}

void GoblinQuest()
{
	if (my_level() >= 5)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"The Goblin Who Wouldn't Be King"))	{
			if (!contains_text(visit_url("plains.php"),"knob2.gif")) {
				if (!have_item($item[Knob Goblin encryption key])) {
					print_goal("Search for encryption key.");
					obtain(1, $item[Knob Goblin encryption key], $location[The Outskirts of Cobb's Knob]);
				}
				use(1, $item[Cobb's Knob map]);
			} else {
				print_goal_complete("Cobb's Knob is already available.");
			}

			if(!haveHaremOutfit()) {
				print_goal("Search for harem outfit.");
				fulfill_condition("haveHaremOutfit",$location[Cobb's Knob Harem]);
			} else {
				print_goal_complete("Already have harem outfit.");
			}
	
			if(haveHaremOutfit()) {
				if (user_confirm("Try for the Glass Balls of the Goblin King?")) {
					update_mcd(3);
				} else if (user_confirm("Try for the Codpiece of the Goblin King?"))	{
					update_mcd(7);
				} else if ((in_mysticality_sign()) && (!contains_text(visit_url("trophies.php"),"Boss Boss")) 
						&& user_confirm("Try for the Boss Boss trophy?"))	{
					update_mcd(11);      
				}
	
				while_abort();
				set_backup_state();
				maximize_strength();
				outfit("Knob Goblin Harem Girl Disguise");
				if(have_item($item[knob goblin perfume])) {
					use(1,$item[knob goblin perfume]);
				} else {
					print_minor_warning("Lose an adventure for perfume");
					adventure(1,$location[Cobb's Knob Harem]);
				}  
				adventure(1, $location[Throne Room]);
				get_backup_state();
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

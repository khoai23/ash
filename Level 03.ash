import <QuestLib.ash>;
import <zlib.ash>;

record array {
	int value;
};

array [int] progressPath;
progressPath[1].value = 4; progressPath[2].value = 3; progressPath[3].value = 2; progressPath[4].value = 1; progressPath[5].value = 6;
progressPath[6].value =11; progressPath[7].value =16; progressPath[8].value =21; progressPath[9].value =17; progressPath[10].value =22;
//[4,3,2,1,6,11,16,21,17,22];

int checkExploringProgress() {
	int counter = 0;
	while(counter<=10) {
		if (contains_text(visit_url("cellar.php"),"cellar.php?action=explore&whichspot="+progressPath[counter].value))
			return counter;
		else
			counter=counter+1;
	}
	return -1;
}

void TavernQuest()
{
	if (my_level() >= 3)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Ooh, I Think I Smell a Rat"))	{
			visit_url("tavern.php?place=barkeep");

			int progress = checkExploringProgress();
			if(progress==-1) abort("Fatal Error, recheck script.");
			string last_page;
			while(get_last_encounter() != "Of Course!" && progress<=10) {
				print_debug("Exploring ("+progress+") at square ("+progressPath[progress].value+")");
				restore_hp(0); restore_mp(0); burn_mp();
				last_page = visit_url("cellar.php?action=explore&whichspot="+progressPath[progress].value);
				if(!contains_text(last_page,"Combat")) {
					run_choice(last_page);
				} else {
					run_combat();
				}
				progress=progress+1;
			}

			visit_url("tavern.php?place=barkeep");
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Ooh, I Think I Smell a Rat"))	{
			print_quest_complete("You have already completed the level 3 quest.");
		}
		else
		{
			print_warning("The level 3 quest is not currently available.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 3 to attempt this quest.");
	}
}

void main()
{
	TavernQuest();
}
import <QuestLib.ash>;
import <zlib.ash>;

string olfact(int round, string opp, string text) {
   if(opp != "dirty old lihc" || (have_effect($effect[On the Trail]) > 0))
      return get_ccs_action(round);
   if(round == 1)
      return "skill transcendent olfaction";
   return get_ccs_action(round - 1);
}

void CyrptQuest()
{
    if (my_level() >= 7)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Cyrptic Emanations"))
		{
			cli_execute("conditions clear");

			if(contains_text(visit_url("crypt.php"),"ul.gif")) {
				vprint("undefiling Nook..","olive",5);
				while(last_monster()!=$monster[giant skeelton]) {
					adventure(1, $location[The Defiled Nook]);
					if(have_item($item[evil eye])) use(1, $item[evil eye]);
					while_abort();
				}
			} else {
				vprint("Nook already undefiled. Moving on","green",1);
			}
			
			// todo automatic olfact
			if(contains_text(visit_url("crypt.php"),"ur.gif")) {
				vprint("undefiling Niche..","olive",4);
				while(last_monster()!=$monster[gargantulihc]) {
					adventure(1, $location[The Defiled Niche]);
					while_abort();
				}
			} else {
				vprint("Niche already undefiled. Moving on","green",1);
			}
			
			if(contains_text(visit_url("crypt.php"),"ll.gif")) {
				vprint("undefiling Cranny..","olive",5);
				while(last_monster()!=$monster[huge ghuol]) {
					adventure(1, $location[The Defiled Cranny]);
					while_abort();
				}
			} else {
				vprint("Cranny already undefiled. Moving on","green",1);
			}
			
			if(contains_text(visit_url("crypt.php"),"lr.gif")) {
				vprint("undefiling Alcove..","olive",5);
				while(last_monster()!=$monster[conjoined zmombie]) {
					adventure(1, $location[The Defiled Alcove]);
					while_abort();
				}
			} else {
				vprint("Alcove already undefiled. Moving on","green",1);
			}
			
			while_abort();

			if (user_confirm("Try for the rib of the Bonerdagon?"))
			{
				change_mcd(5);
			}
			else if (user_confirm("Try for the vertebra of the Bonerdagon?"))
			{
				change_mcd(10);
			}
			else if ((canadia_available()) && (!contains_text(visit_url("trophies.php"),"Boss Boss")))
			{
				if (user_confirm("Try for the Boss Boss trophy?"))
				{
					change_mcd(11);      
				}
			}

			adventure(1, $location[Haert of the Cyrpt]);

			if (available_amount($item[chest of the bonerdagon]) == 1)
			{
				use(1, $item[chest of the bonerdagon]);
			}
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Cyrptic Emanations"))
		{
			vprint("You have already completed the level 7 quest.","green",1);
		}
		else
		{
			vprint("The level 7 quest is not currently available.","black",1);
		}
	}
	else
	{
		vprint("You must be at least level 7 to attempt this quest.","red",1);
	}
}

void main()
{
	CyrptQuest();
}

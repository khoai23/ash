import <QuestLib.ash>;

boolean lastMonsterBossNook() {
	return last_monster()==$monster[giant skeelton];
}
void helpWithNook() {
	if(have_item($item[evil eye])) use(item_amount($item[evil eye]), $item[evil eye]);
}

boolean lastMonsterBossNiche() {
	return last_monster()==$monster[gargantulihc];
}

string olfactHandling() {
	string page = visit_url("adventure.php?snarfblat=263");
	
	if(contains_text(page,"Combat")) {
		if(contains_text(page,"dirty old lihc") && have_effect($effect[On The Trail])==0) {
			page = use_skill($skill[transcendent olfaction]);
		}
		page = run_combat();
	} else {
		page = run_choice(page);
	}
	return page;
}

boolean lastMonsterBossCranny() {
	return last_monster()==$monster[huge ghuol];
}

boolean lastMonsterBossAlcove() {
	return last_monster()==$monster[conjoined zmombie];
}

void CyrptQuest()
{
    if (my_level() >= 7) {
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Cyrptic Emanations")) {
			cli_execute("conditions clear");
			set_backup_state();

			if(contains_text(visit_url("crypt.php"),"ul.gif")) {
				print_goal("undefiling Nook..");
				maximize_item();
				fulfill_condition("lastMonsterBossNook","helpWithNook",$location[The Defiled Nook]);
				get_backup_state();
			} else {
				print_goal_complete("Nook already undefiled. Moving on");
			}
			
			if(contains_text(visit_url("crypt.php"),"ur.gif")) {
				print_goal("undefiling Niche..");
				custom_fight("lastMonsterBossNiche","olfactHandling");
			} else {
				print_goal_complete("Niche already undefiled. Moving on");
			}
			
			if(contains_text(visit_url("crypt.php"),"ll.gif")) {
				print_goal("undefiling Cranny..");
				set_choices(523,4);
				maximize_ml();
				fulfill_condition("lastMonsterBossCranny",$location[The Defiled Cranny]);
				get_backup_state();
			} else {
				print_goal_complete("Cranny already undefiled. Moving on");
			}
			
			if(contains_text(visit_url("crypt.php"),"lr.gif")) {
				print_goal("undefiling Alcove..");
				fulfill_condition("lastMonsterBossAlcove", $location[The Defiled Alcove]);
			} else {
				print_goal_complete("Alcove already undefiled. Moving on");
			}
			
			while_abort();

			if (user_confirm("Try for the rib of the Bonerdagon?"))	{
				change_mcd(5);
			} else if (user_confirm("Try for the vertebra of the Bonerdagon?"))	{
				change_mcd(10);
			} else if (canadia_available() && (!contains_text(visit_url("trophies.php"),"Boss Boss")) 
				&& user_confirm("Try for the Boss Boss trophy?")) {
				change_mcd(11);
			}

			adventure(1, $location[Haert of the Cyrpt]);

			if (have_item($item[chest of the bonerdagon])) {
				use(1, $item[chest of the bonerdagon]);
			}
	
			get_backup_state();
			council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"Cyrptic Emanations")) {
			print_quest_complete("You have already completed the level 7 quest.");
		} else {
			print_warning("The level 7 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 7 to attempt this quest.");
	}
}

void main()
{
	CyrptQuest();
}

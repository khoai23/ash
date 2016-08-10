import <zlib.ash>;

/*
	This lib have several function to aid my other scripts.
	Modify at your own risk.
*/
// CONST
int main_quest_info = 2;
int quest_directive = 3;
int action_directive = 4;
int debug_info = 8;
familiar backup_fam;

// PRINTING FUNCTION
void print_warning(string message,int verbosity) {
	vprint("Not supposed to happen:" + message,"red",verbosity);
}
void print_warning(string message) {
	print_warning(message,main_quest_info);
}
void print_minor_warning(string message) {
	vprint("Minor:" + message,"red",action_directive);
}
void print_quest_complete(string message) {
	vprint("Quest:" + message,"green",main_quest_info);
}
void print_goal(string message) {
	vprint("Goal:" + message,"blue",quest_directive);
}
void print_goal_complete(string message) {
	vprint("Goal:" + message,"green",main_quest_info);
}
void print_debug(string message) {
	vprint(message,"olive",debug_info);
}
void print_not_qualified(string message) {
	vprint("Fail:" + message,"maroon",main_quest_info);
}

// GET/SET/CHECK FUNCTION

string get_last_encounter() {
	return to_string(get_property("lastEncounter"));
}

void set_recklessness(boolean value) {
	set_property("recklessness",to_string(value));
}

boolean get_recklessness() {
	string reckless = get_property("recklessness");
	if(reckless=="") reckless = "false";
	return to_boolean(reckless);
}

boolean have_item(item it) {
	return item_amount(it)>0;
}

void set_choices(int choiceAdventure,int choice) {
	set_property("choiceAdventure"+choiceAdventure,to_string(choice));
}

void set_backup_state() {
	cli_execute("outfit save lib_backup");
	backup_fam = my_familiar();
}

void get_backup_state() {
	cli_execute("outfit lib_backup");
	use_familiar(backup_fam);
}

boolean check_beaten_up() {
	return (!get_recklessness() && (have_effect($effect[Beaten Up])>0));
}

void while_abort() {
	if (my_adventures() == 0){
		get_backup_state();
		abort("Ran out of adventures.");
	} else if(check_beaten_up()) {
		get_backup_state();
		abort("You are not reckless enough to adventure after having your ass whoop'd.");
	}
}

int check_survive_clue() {
	float damage = 13+25+50+125+250;
	int cold_damage = to_int(damage*(100-elemental_resistance($element[cold]))/100);
	int spooky_damage = to_int(damage*(100-elemental_resistance($element[spooky]))/100);
	return my_maxhp() - (cold_damage + spooky_damage);
}

boolean have_saucepan() {
	if(have_item($item[saucepan])) return true;
	if(have_item($item[5-Alarm Saucepan])) return true;
	if(have_item($item[warbear oil pan])) return true;
	if(have_item($item[oil pan])) return true;
	if(have_item($item[17-alarm saucepan])) return true;
	if(have_item($item[Saucepanic])) return true;
	if(have_item($item[Windsor Pan of the Source])) return true;
	if(have_item($item[frying brainpan])) return true;
	return false;
}

void open_pvp() {
	if(contains_text(visit_url("campground.php"),"hippystone.gif")) {
		visit_url("campground.php?pwd&smashstone=Yep.&confirm=checked");
	}
}

int max_mcd() {
	return 10 + ( canadia_available() ? 1 : 0 );
}

void update_mcd(int level) {
	if (current_mcd() != level) change_mcd(level);
}

void increase_mcd() {
	update_mcd(max_mcd());
}

// CHOICE FUNCTION

string run_choice( string page_text ) {
	while( contains_text( page_text , "choice.php" ) )
	{
		## Get choice adventure number
		int begin_choice_adv_num = ( index_of( page_text , "whichchoice value=" ) + 18 );
		int end_choice_adv_num = index_of( page_text , "><input" , begin_choice_adv_num );
		string choice_adv_num = substring( page_text , begin_choice_adv_num , end_choice_adv_num );
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property( choice_adv_prop );
		
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	return page_text;
}

boolean find_adventure(string text, location loc, int adv) {
	string page = "";
	string url = loc.to_url();
	int i = 0;

	text = text.to_lower_case();

	while (my_adventures() > 0 && url > 0)
	{
		page = visit_url(url);

		if (page.contains_text("Combat"))
		{
			page = run_combat();
		}
		else if (page.contains_text("choice.php"))
		{                                                    
			page = run_choice(page);
		}

		page = page.to_lower_case();

        i = i + 1;

		if (page.contains_text(text))
		{
			return true;
		}

		adv = adv - 1;
	}

	return false;
}

// CHANGE FUNCTION

void maximize_resist() {
	if (have_familiar($familiar[Exotic Parrot])) {
		use_familiar($familiar[Exotic Parrot]);
	}
	/*if(have_skill($skill[elemental saucesphere]) && have_saucepan()) {
		use_skill(1,$skill[elemental saucesphere]);
	}
	if(have_skill($skill[ghostly shell])) {
		use_skill(1,$skill[ghostly shell]);
	}*/
	
	maximize("all resistance", get_recklessness());
}

void maximize_item() {
	if (have_familiar($familiar[Jumpsuited Hound Dog])) {
		use_familiar($familiar[Jumpsuited Hound Dog]);
	} else if(have_familiar($familiar[Gelatinous Cubeling])) {
		use_familiar($familiar[Gelatinous Cubeling]);
	}
	maximize("item drop",get_recklessness());
}

void maximize_meat() {
	if (have_familiar($familiar[Hobo Monkey])) {
		use_familiar($familiar[Hobo Monkey]);
	} else if(have_familiar($familiar[Leprechaun])) {
		use_familiar($familiar[Leprechaun]);
	}
	maximize("meat drop",get_recklessness());
}

void maximize_strength() {
	if(in_hardcore()) {
		if (have_familiar($familiar[Adorable Space Buddy])) {
			use_familiar($familiar[Adorable Space Buddy]);
		}
	}
	maximize("mainstat",true);
}

void maximize_noncom() {
	if(my_familiar()==$familiar[Jumpsuited Hound Dog]) {
		print_minor_warning("Familiar detrimental to progress.");
		use_familiar($familiar[Mosquito]);
	}
	maximize("-combat",get_recklessness());
}

void maximize_com() {
	if(have_familiar($familiar[Jumpsuited Hound Dog])) {
		use_familiar($familiar[Jumpsuited Hound Dog]);
	}
	maximize("+combat",get_recklessness());
}

void maximize_cold() {
	if (have_familiar($familiar[Exotic Parrot])) {
		use_familiar($familiar[Exotic Parrot]);
	}
	
	maximize("cold resistance", get_recklessness());
}

void maximize_for_ghost(){
	if(pulls_remaining()>0) {
		if(storage_amount($item[topiary tights])>0&&!have_item($item[topiary tights])) {
			take_storage(1,$item[topiary tights]);
		}
		if(have_item($item[topiary tights])) {
			equip($item[topiary tights]);
		}
		if(can_equip($item[nurse's hat])) {
			if((pulls_remaining()>0) && (storage_amount($item[nurse's hat])>0) && (!have_item($item[nurse's hat]))) {
				take_storage(1,$item[nurse's hat]);
			}
			equip($item[nurse's hat]);
		} else if(can_equip($item[sea shawl])) {
			if((pulls_remaining()>0) && (storage_amount($item[sea shawl])>0) && (!have_item($item[sea shawl]))) {
				take_storage(1,$item[sea shawl]);
			}
			equip($item[sea shawl]);
		} else if(can_equip($item[sea salt scrubs])) {
			if((pulls_remaining()>0) && (storage_amount($item[sea salt scrubs])>0) && (!have_item($item[sea salt scrubs]))) {
				take_storage(1,$item[sea salt scrubs]);
			}
			equip($item[sea salt scrubs]);
		} else {
			print_not_qualified("No +hp item to pull.");
		}
	}
	
	maximize("maximum hp, cold resistance, spooky resistance", get_recklessness());
	
	int checker = check_survive_clue();
	if(checker>0) {
		if(my_maxhp()-my_hp()>checker) restore_hp(my_maxhp()-checker+1);
	} else {
		abort("You need "+(-checker+1)+"more max hp to clear it with clue.");
	}
}

// HYBRID FUNCTION

void burn_mp() {
	int threshold = to_int(to_float(get_property("manaBurningThreshold"))*to_float(my_maxmp()));
	int trigger = to_int(to_float(get_property("manaBurningTrigger"))*to_float(my_maxmp()));
	if(my_mp()>trigger) {
		cli_execute("burn " + (my_mp()-threshold) + " mp");
	}
}

// IN ADVENTURE FUNCTION

buffer use_macro(string id) {
	return visit_url("fight.php?action=macro&whichmacro="+id);
}

buffer manual_run_choice(int choiceNumber,int choice) {
	return visit_url("choice.php?pwd&whichchoice="+choiceNumber+"&option="+choice);
}

// AUTOMATON FUNCTION

void obtain_outfit(string outfit, location loc) {
	print_debug("@obtain_outfit outfit:"+outfit+"|loc:"+loc);
	while(!have_outfit(outfit) && !is_wearing_outfit(outfit)) {
		adventure(1,loc,"");
		while_abort();
	}
}

void custom_fight(string cond, string exec) {
	print_debug("@custom_fight_with_exec condition:"+cond+"|exec:"+exec);
	while(!call boolean cond()) {
		while_abort();
		restore_hp(0);
		restore_mp(0);
		burn_mp();
		call string exec();
	}
}

void custom_fight(string cond, string exec, boolean param) {
	print_debug("@custom_fight_with_exec condition:"+cond+"|exec:"+exec+"|param:"+to_string(param));
	while(!call boolean cond()) {
		while_abort();
		restore_hp(0);
		restore_mp(0);
		burn_mp();
		call string exec(param);
	}
}

void fulfill_condition(string cond, location loc) {
	print_debug("@fulfill_condition condition:"+cond+"|loc:"+to_string(loc));
	while(!call boolean cond()) {
		while_abort();
		adv1(loc,-1,"");
	}
}

void fulfill_condition(string cond, string add_exec, location loc) {
	print_debug("@fulfill_condition_with_exec condition:"+cond+"|add_exec:"+add_exec+"|loc:"+to_string(loc));
	while(!call boolean cond()) {
		while_abort();
		adv1(loc,-1,"");
		call add_exec();
	}
}

void open_location(string parent_url, string loc, location place) {
	print_debug("@open_location parentUrl:"+parent_url+"|fingerprint:"+loc+"|location:"+to_string(place));
	while(!contains_text(visit_url(parent_url),loc)) {
		while_abort();
		adventure(1,place);
	}
}

void open_location(string parent_url, string loc, string add_exec, location place) {
	print_debug("@open_location_with_exec parentUrl:"+parent_url+"|fingerprint:"+loc+"|add_exec:"+add_exec+"|location:"+to_string(place));
	while(!contains_text(visit_url(parent_url),loc)) {
		while_abort();
		adventure(1,place);
		call add_exec();
	}
}

boolean test() {
	return my_adventures() > 43;
}

// DAILY FUNCTION

void use_still() {
	string page = visit_url("shop.php?whichshop=still");
}


boolean acquire_token() {
	int token_amount = item_amount($item[fat loot token]);
	set_backup_state();
	if(have_familiar($familiar[Gelatinous Cubeling])) {
		if(!have_item($item[eleven-foot pole]) || !have_item($item[Pick-o-Matic lockpicks]) 
		|| (equipped_amount($item[ring of Detect Boring Doors])==0 &&!have_item($item[ring of Detect Boring Doors]))) {
			abort("You have not gotten all the tools from the Gelatinous Cubeling. Adventure at other place with Gelatinous Cubeling and try again.");
		} else {
			equip($slot[acc3],$item[ring of Detect Boring Doors]);
			set_choices(692,3); // use lockpick
			set_choices(693,2); // use pole
			set_choices(690,2); // use boring door
			set_choices(691,2); // use boring door
		}
	} else {
		if(my_primestat()==$stat[muscle])
			set_choices(692,4); // force door
		else if(my_primestat()==$stat[muscle])
			set_choices(692,5); // magic door
		else
			set_choices(692,6); // slip door
		set_choices(693,1); // bruteforce
		set_choices(690,3); // ignore chest
		set_choices(691,3); // ignore chest
	}
	while(get_last_encounter()!="Daily Done, John.") {
		while_abort();
		adv1($location[The Daily Dungeon],-1,"");
	}
	get_backup_state();
	if(token_amount==item_amount($item[fat loot token])) {
		abort("Token acquired today. Try tomorrow, or pull game magazine!");
		return false;
	} else {
		return true;
	}
}

void main()
{
	vprint("Used for testing new function and config.","blue",1);
	open_pvp();
	acquire_token();
	boolean choice = user_confirm("Do you wish to be reckless and (maybe) get your ass beaten?");
	set_recklessness(choice);
	vprint("Recklessness: " + choice,"blue",1);
	//string func = "test";
	//fulfill_condition("test",$location[The Thinknerd Warehouse]);
}

// DEPRECATED

void set_transfer_value(boolean value) {
	set_property("script_transfer",to_string(value));
}

boolean get_transfer_value() {
	string value = get_property("script_transfer");
	if(value=="") value = "false";
	return to_boolean(value);
}

void run_function(string func_loc, string func, string param) {
	cli_execute("ashq import <"+func_loc+".ash> "+func+"(+param+)");
}

boolean run_function(string func_loc, string func) {
	cli_execute("ashq import <"+func_loc+".ash> "+func+"()");
	return get_transfer_value();
}


void fulfill_condition(string cond_loc, string cond, location loc, int end) {
	while(run_function(cond_loc,cond)) {
		while_abort();
		adv1(loc,-1,"");
	}
}

void custom_fight(string script_loc, string exec,string param) {
	while(get_transfer_value()) {
		while_abort();
		restore_hp(0);
		restore_mp(0);
		burn_mp();
		run_function(script_loc,exec,param);
	}
}

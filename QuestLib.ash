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
	vprint("Minor:" + message,"red",quest_directive);
}
void print_quest_complete(string message) {
	vprint("Quest:" + message,"green",main_quest_info);
}
void print_goal(string message) {
	vprint("Goal:" + message,"blue",quest_directive);
}
void print_goal_complete(string message) {
	vprint("Goal:" + message,"green",quest_directive);
}
void print_debug(string message) {
	vprint(message,"olive",debug_info);
}
void print_combat_info(string message) {
	vprint("Combat:" + message,"magenta",action_directive);
}
void print_not_qualified(string message) {
	vprint("Fail:" + message,"maroon",main_quest_info);
}

// IN ADVENTURE FUNCTION

buffer use_macro(string id) {
	return visit_url("fight.php?action=macro&whichmacro="+id);
}

buffer manual_run_choice(int choiceNumber,int choice) {
	return visit_url("choice.php?pwd&whichchoice="+choiceNumber+"&option="+choice);
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

void res_abort(string message) {
	get_backup_state();
	abort(message);
}

void while_abort() {
	if (my_adventures() == 0){
		res_abort("Ran out of adventures.");
	} else if(check_beaten_up()) {
		res_abort("You are not reckless enough to adventure after having your ass whoop'd.");
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

void run_pvp() {
	if(contains_text(visit_url("campground.php"),"hippystone.gif")) {
		visit_url("campground.php?pwd&smashstone=Yep.&confirm");
	}
	
	if(pvp_attacks_left()>0)
		cli_execute("pvp " + pvp_attacks_left() + " fame 0");
	else	
		print_minor_warning("No pvp fight left.");
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
		
		if(to_int(choice_adv_num)>=890 && to_int(choice_adv_num)<=903) {
			print_debug("Ignore the Light Out Quest.");
			choice_num = "1";
		}
		if(to_int(choice_adv_num)==189) {
			print_debug("Automate the El Vibrato Sphere.");
			manual_run_choice(189,1);
			page_text = visit_url("ocean.php?lon=59&lat=10");
			return page_text;
		}
		
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		print_debug("@run_choice, choice "+choice_adv_num+", option "+choice_num);
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	return page_text;
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
	
	maximize("all resistance", !get_recklessness());
}

void maximize_item() {
	if (have_familiar($familiar[Jumpsuited Hound Dog])) {
		use_familiar($familiar[Jumpsuited Hound Dog]);
	} else if(have_familiar($familiar[Gelatinous Cubeling])) {
		use_familiar($familiar[Gelatinous Cubeling]);
	}
	maximize("item drop",!get_recklessness());
}

void maximize_meat() {
	if (have_familiar($familiar[Hobo Monkey])) {
		use_familiar($familiar[Hobo Monkey]);
	} else if(have_familiar($familiar[Leprechaun])) {
		use_familiar($familiar[Leprechaun]);
	}
	maximize("meat drop",!get_recklessness());
}

void maximize_init() {
	if(have_familiar($familiar[Xiblaxian Holo-Companion])) {
		use_familiar($familiar[Xiblaxian Holo-Companion]);
	} else if(have_familiar($familiar[Oily Woim])) {
		use_familiar($familiar[Oily Woim]);
	}
	
	maximize("initiative",!get_recklessness());
}

void maximize_strength() {
	change_mcd(0);
	if(in_hardcore()) {
		if (have_familiar($familiar[Adorable Space Buddy])) {
			use_familiar($familiar[Adorable Space Buddy]);
		}
	}
	maximize("mainstat",false);
}

void maximize_ml() {
	change_mcd(max_mcd());
	if(have_familiar($familiar[Purse Rat])) {
		use_familiar($familiar[Purse Rat]);
	}
	maximize("ml",!get_recklessness());
}

void maximize_noncom() {
	if(my_familiar()==$familiar[Jumpsuited Hound Dog]) {
		print_minor_warning("Familiar detrimental to progress.");
		use_familiar($familiar[Mosquito]);
	}
	maximize("-combat",!get_recklessness());
}

void maximize_com() {
	if(have_familiar($familiar[Jumpsuited Hound Dog])) {
		use_familiar($familiar[Jumpsuited Hound Dog]);
	}
	maximize("+combat",!get_recklessness());
}

void maximize_cold() {
	if (have_familiar($familiar[Exotic Parrot])) {
		use_familiar($familiar[Exotic Parrot]);
	}
	
	maximize("cold resistance", !get_recklessness());
}

void maximize_stench() {
	if (have_familiar($familiar[Exotic Parrot])) {
		use_familiar($familiar[Exotic Parrot]);
	}
	
	maximize("stench resistance", !get_recklessness());
}

void maximize_hp() {
	maximize("maximum hp",false);
}

void maximize_for_ghost(){
	if (have_familiar($familiar[Exotic Parrot])) {
		use_familiar($familiar[Exotic Parrot]);
	}
	
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
	
	if(have_effect($effect[Go Get 'Em\, Tiger!])==0) {
		buy(1,$item[Ben-Gal&trade; Balm]);
		use(1,$item[Ben-Gal&trade; Balm]);
	}
	
	maximize("maximum hp, cold resistance, spooky resistance", false);
	
	int checker = check_survive_clue();
	if(checker>0) {
		if(my_maxhp()-my_hp()>checker) restore_hp(my_maxhp()-checker+1);
	} else {
		res_abort("You need "+(-checker+1)+"more max hp to clear it with clue.");
	}
}

void maximize_surgeon() {
	if(get_recklessness() || (equipped_amount($item[surgical apron]) + equipped_amount($item[bloodied surgical dungarees])
		+ equipped_amount($item[surgical mask]) + equipped_amount($item[head mirror]) + equipped_amount($item[half-size scalpel]) == 0)) {
		if(have_item($item[surgical apron])) equip($item[surgical apron]);
		if(have_item($item[bloodied surgical dungarees])) equip($item[bloodied surgical dungarees]);
		if(have_item($item[surgical mask])) equip($slot[acc3],$item[surgical mask]);
		if(have_item($item[head mirror])) equip($slot[acc2],$item[head mirror]);
		if(get_recklessness())
			if(have_item($item[half-size scalpel])) equip($slot[weapon],$item[half-size scalpel]);
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

boolean adv1(location loc) {
	return adv1(loc,-1,"");
}

// AUTOMATON FUNCTION

void obtain_item(int num, item it, location loc) {
	obtain(num,it,loc);
	if(item_amount(it)<num) {
		res_abort("Obtain failed, executing rollback.");
	}
}

void obtain_item(int num, string it, location loc) {
	obtain(num,it,loc);
	if(item_amount(to_item(it))<num) {
		res_abort("Obtain failed, executing rollback.");
	}
}

void obtain_outfit(string outfit, location loc) {
	print_debug("@obtain_outfit outfit:"+outfit+"|loc:"+loc);
	cli_execute("conditions clear");
	while(!have_outfit(outfit) && !is_wearing_outfit(outfit)) {
		adv1(loc);
		while_abort();
	}
}

void custom_fight(string cond, string exec) {
	print_debug("@custom_fight_with_exec condition:"+cond+"|exec:"+exec);
	while(!call boolean cond()) {
		restore_hp(0);
		restore_mp(0);
		burn_mp();
		call string exec();
		while_abort();
	}
}

void custom_fight(string cond, string exec, boolean param) {
	print_debug("@custom_fight_with_exec condition:"+cond+"|exec:"+exec+"|param:"+to_string(param));
	while(!call boolean cond()) {
		restore_hp(0);
		restore_mp(0);
		burn_mp();
		call string exec(param);
		while_abort();
	}
}

void fulfill_condition(string cond, location loc) {
	print_debug("@fulfill_condition condition:"+cond+"|loc:"+to_string(loc));
	cli_execute("conditions clear");
	while(!call boolean cond()) {
		while_abort();
		adv1(loc);
	}
}

void fulfill_condition(string cond, string add_exec, location loc) {
	print_debug("@fulfill_condition_with_exec condition:"+cond+"|add_exec:"+add_exec+"|loc:"+to_string(loc));
	cli_execute("conditions clear");
	while(!call boolean cond()) {
		while_abort();
		adv1(loc);
		call add_exec();
	}
}

void open_location(string parent_url, string loc, location place) {
	print_debug("@open_location parentUrl:"+parent_url+"|fingerprint:"+loc+"|location:"+to_string(place));
	cli_execute("conditions clear");
	while(!contains_text(visit_url(parent_url),loc)) {
		adv1(place);
		while_abort();
	}
}

void open_location(string parent_url, string loc, string add_exec, location place) {
	print_debug("@open_location_with_exec parentUrl:"+parent_url+"|fingerprint:"+loc+"|add_exec:"+add_exec+"|location:"+to_string(place));
	while(!contains_text(visit_url(parent_url),loc)) {
		adv1(place);
		call add_exec();
		while_abort();
	}
}

// DAILY FUNCTION
int still_list = 5;
item[int] still_ingr;
item[int] still_res;
still_ingr[1] = $item[bottle of rum]; still_res[1] = $item[bottle of Lieutenant Freeman];
still_ingr[2] = $item[olive]; still_res[2] = $item[cocktail onion];
still_ingr[3] = $item[bottle of gin]; still_res[3] = $item[bottle of Calcutta Emerald];
still_ingr[4] = $item[lemon]; still_res[4] = $item[kiwi];
still_ingr[5] = $item[orange]; still_res[5] = $item[kumquat];
still_ingr[6] = $item[soda water]; still_res[6] = $item[tonic water];

void use_still() {
	if(my_primestat()!=$stat[moxie]) {
		print_minor_warning("You don't have access to the still.");
		return;
	}
	
	if(stills_available()==0) {
		print_minor_warning("Out of converting juice. Return tomorrow.");
		return;
	}
	for i from 1 upto still_list {
		if(stills_available()==0) return;
		if(have_item(still_ingr[i])) {
			create(min(stills_available(),item_amount(still_ingr[i])),still_res[i]);
		}
	} 
	if(stills_available()>0) {
		if(item_amount($item[soda water])<stills_available()) {
			buy(stills_available()-item_amount($item[soda water]),$item[soda water]);
			//visit_url("shop.php?whichshop=still&action=buyitem&quantity="+stills_available()+"&whichrow=279&pwd");
		}
		create(stills_available(),$item[tonic water]);
	}
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
		print_minor_warning("Token acquired today. Try tomorrow, or pull game magazine!");
		return false;
	} else {
		return true;
	}
}

void test() {
	matcher mtc = create_matcher("\\w+\\.gif",visit_url("main.php"));
	while(find(mtc)) {
		print(group(mtc));
	}
}

void main()
{
	print("Used for testing new function and config.","blue");
	//test();
	boolean choice = user_confirm("Do you wish to be reckless and (maybe) get your ass beaten?");
	vprint("Recklessness: " + choice,"blue",1);
	set_recklessness(choice);
	run_pvp();
	acquire_token();
	use_still();
}
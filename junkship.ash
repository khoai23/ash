script "junkship.ash";
import <QuestLib.ash>;
void setAdventure() {
	if(!have_item($item[old claw-foot bathtub])) set_choices(794,1);
	else if(!have_item($item[old clothesline pole])) set_choices(794,2);
	else set_choices(794,3);
}
void main() {	
	if(contains_text(visit_url("woods.php"),"smokesignals.gif")) {
		print("Talking to the stranded hippy..","blue");
		visit_url("place.php?whichplace=woods&action=woods_smokesignals");
		visit_url("choice.php?pwd&whichchoice=798&option=1");
		visit_url("choice.php?pwd&whichchoice=798&option=2");
	}
	if(contains_text(visit_url("questlog.php?which=1"),"Give a Hippy a Boat")) {
		
		set_choices(795,1);
		set_choices(796,2);
		set_choices(797,3);
		setAdventure();
		while(!have_item($item[junk junk])) {
			while_abort();
			adventure(1,$location[The Old Landfill]);
			setAdventure();
			if(have_item($item[old claw-foot bathtub]) && have_item($item[old clothesline pole])
			   && have_item($item[antique cigar sign])) {
				cli_execute("/buy junk junk");
			}
		}
		
		print("Bringing the boat to the hippy.","blue");
		visit_url("place.php?whichplace=woods&action=woods_hippy");
	} else if(contains_text(visit_url("questlog.php?which=2"),"Give a Hippy a Boat")) {
		print("You have already gave a boat to a stranded hippy.","green");
	} else {
		print("You can't do the quest, for some explicable reason.");
	}
}
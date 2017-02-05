/* Base Defense stock functions v0.12
 *
 * (c) 2015, JonnyBoy0719
 *
 * This file is provided as is (no warranties).
 */

#if defined _bdef_included
  #endinput
#endif
#define _bdef_included

#include <engine>
#include <fakemeta>
#include <maths>

/********************************************************************/
/*                      REQUIRES ENGINE TO USE!                     */
/********************************************************************/
/*                     REQUIRES FAKEMETA TO USE!                    */
/********************************************************************/

// Chat Colors
//#define COLOR_ADDITIVE		"^^0"	// No longer exists!
#define COLOR_DEFAULT		"^^1"
#define COLOR_RED			"^^2"
#define COLOR_GREEN			"^^3"
#define COLOR_BLUE			"^^4"
#define COLOR_ORANGE		"^^5"
#define COLOR_BROWN			"^^6"
#define COLOR_LIGHTBLUE		"^^7"
#define COLOR_GRAY			"^^8"
#define COLOR_NORMAL		"^^9"

// IDS
#define get_level			26
#define get_money			25
#define get_mana			1101
#define get_mana_max		1102
#define get_hps				1132
#define get_hps_max			1130
#define get_legerity		27
#define get_precision		28
#define get_toughness		29
#define get_sorcery			30
#define get_exp_min			1098
#define get_exp_max			1099
#define get_points			1100
#define get_item_hp			1087
#define get_item_mana		1088

stock bdef_get_user_level(id) {
	return get_pdata_int(id, get_level);
}

stock bdef_get_user_money(id) {
	return get_pdata_int(id, get_money);
}

stock bdef_get_user_mana(id) {
	return get_pdata_int(id, get_mana);
}

stock bdef_get_user_mana_max(id) {
	return get_pdata_int(id, get_mana_max);
}

stock bdef_get_user_hps(id) {
	return get_pdata_int(id, get_hps);
}

stock bdef_get_user_hps_max(id) {
	return get_pdata_int(id, get_hps_max);
}

stock bdef_get_user_skill_legerity(id) {
	return get_pdata_int(id, get_legerity);
}

stock bdef_get_user_skill_precision(id) {
	return get_pdata_int(id, get_precision);
}

stock bdef_get_user_skill_toughness(id) {
	return get_pdata_int(id, get_toughness);
}

stock bdef_get_user_skill_sorcery(id) {
	return get_pdata_int(id, get_sorcery);
}

stock bdef_get_user_exp_min(id) {
	return get_pdata_int(id, get_exp_min);
}
stock bdef_get_user_exp_max(id) {
	return get_pdata_int(id, get_exp_max);
}

stock bdef_get_user_points(id) {
	return get_pdata_int(id, get_points);
}

stock bdef_get_user_item_health(id) {
	return get_pdata_int(id, get_item_hp);
}

stock bdef_get_user_item_mana(id) {
	return get_pdata_int(id, get_item_mana);
}

/********************************************************************/

// Updates everything on the HUD.
stock bdef_update_user_hud(id) {
	bdef_update_user_skills(id);
	bdef_update_user_belt(id);
}

stock bdef_update_user_skills(id) {
	static gmsgPlrStats;
	if (!gmsgPlrStats)
		gmsgPlrStats = get_user_msgid("PlrStats");
	message_begin( MSG_ONE, gmsgPlrStats, {0,0,0}, id );
	write_byte( bdef_get_user_skill_legerity(id) );
	write_byte( bdef_get_user_skill_precision(id) );
	write_byte( bdef_get_user_skill_toughness(id) );
	write_byte( bdef_get_user_skill_sorcery(id) );
	write_byte( bdef_get_user_points(id) );
	message_end();
}

stock bdef_update_user_belt(id) {
	static gmsgBelt;
	if (!gmsgBelt)
		gmsgBelt = get_user_msgid("Belt");
	message_begin( MSG_ONE, gmsgBelt, {0,0,0}, id );
	write_byte( bdef_get_user_item_health(id) );
	write_byte( bdef_get_user_item_mana(id) );
	message_end();
}

/********************************************************************/

stock bdef_add_user_level(id) {
	new m_iTargetExp = bdef_get_user_exp_max(id) + (400 * fpower(1.145, 1));
	bdef_set_user_exp_max(id, m_iTargetExp)
	return bdef_set_user_level(id, bdef_get_user_level(id) + 1);
}

stock bdef_set_user_level(id, value) {	
	if (value <= 1)
	{
		bdef_set_user_exp_min(id, 0)
		bdef_set_user_exp_max(id, 300)
	}
	
	bdef_set_user_points(id, value)
	return set_pdata_int(id, get_level, value);
}

stock bdef_set_user_money(id, value) {
	return set_pdata_int(id, get_money, value);
}

stock bdef_set_user_mana(id, value) {
	return set_pdata_int(id, get_mana, value);
}

stock bdef_set_user_mana_max(id, value) {
	return set_pdata_int(id, get_mana_max, value);
}

stock bdef_set_user_hps(id, value) {
	return set_pdata_int(id, get_hps, value);
}

stock bdef_set_user_hps_max(id, value) {
	return set_pdata_int(id, get_hps_max, value);
}

stock bdef_set_user_skill_legerity(id, value) {
	return set_pdata_int(id, get_legerity, value);
}

stock bdef_set_user_skill_precision(id, value) {
	return set_pdata_int(id, get_precision, value);
}

stock bdef_set_user_skill_toughness(id, value) {
	return set_pdata_int(id, get_toughness, value);
}

stock bdef_set_user_skill_sorcery(id, value) {
	return set_pdata_int(id, get_sorcery, value);
}

stock bdef_set_user_exp_min(id, value) {
	return set_pdata_int(id, get_exp_min, value);
}
stock bdef_set_user_exp_max(id, value) {
	return set_pdata_int(id, get_exp_max, value);
}

stock bdef_set_user_points(id, value) {
	return set_pdata_int(id, get_points, value);
}

stock bdef_set_user_item_health(id, value) {
	return set_pdata_int(id, get_item_hp, value);
}

stock bdef_set_user_item_mana(id, value) {
	return set_pdata_int(id, get_item_mana, value);
}

/* Base Defense stock functions v0.11
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
#if defined OLDVALUE
#define COLOR_ADDITIVE		"^^0"
#define COLOR_DEFAULT		"^^1"
#define COLOR_RED			"^^2"
#define COLOR_GREEN			"^^3"
#define COLOR_BLUE			"^^4"
#define COLOR_ORANGE		"^^5"
#define COLOR_BROWN			"^^6"
#define COLOR_LIGHTBLUE		"^^7"
#define COLOR_GRAY			"^^8"
#define COLOR_NORMAL		"^^9"
#else
#define COLOR_ADDITIVE		"~0"
#define COLOR_DEFAULT		"~1"
#define COLOR_RED			"~2"
#define COLOR_GREEN			"~3"
#define COLOR_BLUE			"~4"
#define COLOR_ORANGE		"~5"
#define COLOR_BROWN			"~6"
#define COLOR_LIGHTBLUE		"~7"
#define COLOR_GRAY			"~8"
#define COLOR_NORMAL		"~9"
#endif

stock bdef_get_user_level(id) {
	return get_pdata_int(id, 28);
}

stock bdef_get_user_money(id) {
	return get_pdata_int(id, 27);
}

stock bdef_get_user_mana(id) {
	return get_pdata_int(id, 437, -1);
}

stock bdef_get_user_mana_max(id) {
	return get_pdata_int(id, 435, -1);
}

stock bdef_get_user_hps(id) {
	return get_pdata_int(id, 436, -1);
}

stock bdef_get_user_hps_max(id) {
	return get_pdata_int(id, 434, -1);
}

stock bdef_get_user_skill_legerity(id) {
	return get_pdata_int(id, 29);
}

stock bdef_get_user_skill_precision(id) {
	return get_pdata_int(id, 30);
}

stock bdef_get_user_skill_toughness(id) {
	return get_pdata_int(id, 31);
}

stock bdef_get_user_skill_sorcery(id) {
	return get_pdata_int(id, 32);
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

stock bdef_get_user_exp_min(id) {
	return get_pdata_int(id, 404);
}
stock bdef_get_user_exp_max(id) {
	return get_pdata_int(id, 405);
}

stock bdef_get_user_points(id) {
	return get_pdata_int(id, 406);
}

stock bdef_get_user_task(id) {
	return get_pdata_int(id, 33);
}

stock bdef_get_user_item_health(id) {
	return get_pdata_int(id, 400);
}

stock bdef_get_user_item_mana(id) {
	return get_pdata_int(id, 401);
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
	return set_pdata_int(id, 28, value);
}

stock bdef_set_user_money(id, value) {
	return set_pdata_int(id, 27, value);
}

stock bdef_set_user_mana(id, value) {
	return set_pdata_int(id, 437, value, -1);
}

stock bdef_set_user_mana_max(id, value) {
	return set_pdata_int(id, 435, value, -1);
}

stock bdef_set_user_hps(id, value) {
	return set_pdata_int(id, 436, value, -1);
}

stock bdef_set_user_hps_max(id, value) {
	return set_pdata_int(id, 434, value, -1);
}

stock bdef_set_user_skill_legerity(id, value) {
	return set_pdata_int(id, 29, value);
}

stock bdef_set_user_skill_precision(id, value) {
	return set_pdata_int(id, 30, value);
}

stock bdef_set_user_skill_toughness(id, value) {
	return set_pdata_int(id, 31, value);
}

stock bdef_set_user_skill_sorcery(id, value) {
	return set_pdata_int(id, 32, value);
}

stock bdef_set_user_exp_min(id, value) {
	return set_pdata_int(id, 404, value);
}
stock bdef_set_user_exp_max(id, value) {
	return set_pdata_int(id, 405, value);
}

stock bdef_set_user_points(id, value) {
	return set_pdata_int(id, 406, value);
}

stock bdef_set_user_task(id, value) {
	return set_pdata_int(id, 33, value);
}

stock bdef_set_user_item_health(id, value) {
	return set_pdata_int(id, 400, value);
}

stock bdef_set_user_item_mana(id, value) {
	return set_pdata_int(id, 401, value);
}

<!--
var S_msg_no = "No related files";
function JF_SafetyController_SelfTest() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_c/safety_controller.html#LN29";
	idxary[0] = "../safety_controller_c/safety_controller_idx.html";
	jumpary[1] = "../safety_controller_c/SafetyController_Self&0003_vcht1.html";
	idxary[1] = "../safety_controller_c/SafetyController_Self&0003_vcht_idx.html";
	jumpary[2] = "../safety_controller_c/SafetyController_Self&0003_vmod.html";
	idxary[2] = "../safety_controller_c/SafetyController_Self&0003_vmod_idx.html";
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = "../ChartList/project_vblk1.html";
	idxary[4] = "../ChartList/project_vblk_idx.html";
	jumpary[5] = "safety_controller_vblk1.html";
	idxary[5] = "safety_controller_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "safety_controller_vmlt.html";
	idxary[7] = "safety_controller_vmlt_idx.html";
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				if( i == 0 )
				{
					i = 3;
				}
				else
				{
					alert(S_msg_no);
					break;
				}
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JT_SafetyOutput() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_h/safety_controller.html#LN13";
	idxary[0] = "../safety_controller_h/safety_controller_idx.html";
	jumpary[1] = null;
	idxary[1] = null;
	jumpary[2] = null;
	idxary[2] = null;
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = null;
	idxary[4] = null;
	jumpary[5] = null;
	idxary[5] = null;
	jumpary[6] = null;
	idxary[6] = null;
	jumpary[7] = null;
	idxary[7] = null;
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				alert(S_msg_no);
				break;
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JM_safeSpeed2SafetyOutput() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_h/safety_controller.html#LN10";
	idxary[0] = "../safety_controller_h/safety_controller_idx.html";
	jumpary[1] = null;
	idxary[1] = null;
	jumpary[2] = null;
	idxary[2] = null;
	jumpary[3] = "../safety_controller_h/SafetyOutput&0001_vdat.html";
	idxary[3] = "../safety_controller_h/SafetyOutput&0001_vdat_idx.html";
	jumpary[4] = null;
	idxary[4] = null;
	jumpary[5] = null;
	idxary[5] = null;
	jumpary[6] = null;
	idxary[6] = null;
	jumpary[7] = null;
	idxary[7] = null;
	jumpary[8] = "../ChartList/project_vdlt.html";
	idxary[8] = "../ChartList/project_vdlt_idx.html";
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				alert(S_msg_no);
				break;
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JF_clamp_int() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_c/safety_controller.html#LN15";
	idxary[0] = "../safety_controller_c/safety_controller_idx.html";
	jumpary[1] = "../safety_controller_c/clamp_int&0002_vcht1.html";
	idxary[1] = "../safety_controller_c/clamp_int&0002_vcht_idx.html";
	jumpary[2] = "../safety_controller_c/clamp_int&0002_vmod.html";
	idxary[2] = "../safety_controller_c/clamp_int&0002_vmod_idx.html";
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = "../ChartList/project_vblk1.html";
	idxary[4] = "../ChartList/project_vblk_idx.html";
	jumpary[5] = "safety_controller_vblk1.html";
	idxary[5] = "safety_controller_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "safety_controller_vmlt.html";
	idxary[7] = "safety_controller_vmlt_idx.html";
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				if( i == 0 )
				{
					i = 3;
				}
				else
				{
					alert(S_msg_no);
					break;
				}
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JM_safeTorque2SafetyOutput() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_h/safety_controller.html#LN11";
	idxary[0] = "../safety_controller_h/safety_controller_idx.html";
	jumpary[1] = null;
	idxary[1] = null;
	jumpary[2] = null;
	idxary[2] = null;
	jumpary[3] = "../safety_controller_h/SafetyOutput&0001_vdat.html";
	idxary[3] = "../safety_controller_h/SafetyOutput&0001_vdat_idx.html";
	jumpary[4] = null;
	idxary[4] = null;
	jumpary[5] = null;
	idxary[5] = null;
	jumpary[6] = null;
	idxary[6] = null;
	jumpary[7] = null;
	idxary[7] = null;
	jumpary[8] = "../ChartList/project_vdlt.html";
	idxary[8] = "../ChartList/project_vdlt_idx.html";
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				alert(S_msg_no);
				break;
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JF_main() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_c/safety_controller.html#LN6";
	idxary[0] = "../safety_controller_c/safety_controller_idx.html";
	jumpary[1] = "../safety_controller_c/main&0001_vcht1.html";
	idxary[1] = "../safety_controller_c/main&0001_vcht_idx.html";
	jumpary[2] = "../safety_controller_c/main&0001_vmod.html";
	idxary[2] = "../safety_controller_c/main&0001_vmod_idx.html";
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = "../ChartList/project_vblk1.html";
	idxary[4] = "../ChartList/project_vblk_idx.html";
	jumpary[5] = "safety_controller_vblk1.html";
	idxary[5] = "safety_controller_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "safety_controller_vmlt.html";
	idxary[7] = "safety_controller_vmlt_idx.html";
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				if( i == 0 )
				{
					i = 3;
				}
				else
				{
					alert(S_msg_no);
					break;
				}
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JF_WinAMS_SPMC_Init() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_c/safety_controller.html#LN3";
	idxary[0] = "../safety_controller_c/safety_controller_idx.html";
	jumpary[1] = null;
	idxary[1] = null;
	jumpary[2] = null;
	idxary[2] = null;
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = null;
	idxary[4] = null;
	jumpary[5] = null;
	idxary[5] = null;
	jumpary[6] = null;
	idxary[6] = null;
	jumpary[7] = null;
	idxary[7] = null;
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				alert(S_msg_no);
				break;
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JM_faultActive2SafetyOutput() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_h/safety_controller.html#LN12";
	idxary[0] = "../safety_controller_h/safety_controller_idx.html";
	jumpary[1] = null;
	idxary[1] = null;
	jumpary[2] = null;
	idxary[2] = null;
	jumpary[3] = "../safety_controller_h/SafetyOutput&0001_vdat.html";
	idxary[3] = "../safety_controller_h/SafetyOutput&0001_vdat_idx.html";
	jumpary[4] = null;
	idxary[4] = null;
	jumpary[5] = null;
	idxary[5] = null;
	jumpary[6] = null;
	idxary[6] = null;
	jumpary[7] = null;
	idxary[7] = null;
	jumpary[8] = "../ChartList/project_vdlt.html";
	idxary[8] = "../ChartList/project_vdlt_idx.html";
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				alert(S_msg_no);
				break;
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
function JF_SafetyController() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../safety_controller_c/safety_controller.html#LN41";
	idxary[0] = "../safety_controller_c/safety_controller_idx.html";
	jumpary[1] = "../safety_controller_c/SafetyController&0004_vcht1.html";
	idxary[1] = "../safety_controller_c/SafetyController&0004_vcht_idx.html";
	jumpary[2] = "../safety_controller_c/SafetyController&0004_vmod.html";
	idxary[2] = "../safety_controller_c/SafetyController&0004_vmod_idx.html";
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = "../ChartList/project_vblk1.html";
	idxary[4] = "../ChartList/project_vblk_idx.html";
	jumpary[5] = "safety_controller_vblk1.html";
	idxary[5] = "safety_controller_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "safety_controller_vmlt.html";
	idxary[7] = "safety_controller_vmlt_idx.html";
	jumpary[8] = null;
	idxary[8] = null;
	var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
	if(sp_index==0)
		return;
	for( i=1; i<=9; i++ ){
		if(sp_index==i){
			if( jumpary[i-1] == null ){
				if( i == 0 )
				{
					i = 3;
				}
				else
				{
					alert(S_msg_no);
					break;
				}
			}
			parent.MAIN.location.href=jumpary[i-1];
			parent.INDEX.location.href=idxary[i-1];
			break;
		}
	}
}
	function JumpSrc(curdir,reldir,lnno){
		var idx = curdir + reldir + "_idx.html";
		var jump = curdir + reldir + ".html#LN" + lnno;
		parent.MAIN.location.href=jump;
		parent.INDEX.location.href=idx;
	}
//-->

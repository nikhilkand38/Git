<!--
var S_msg_no = "No related files";
function JF__start() {
	var jumpary = new Array(9);
	var idxary = new Array(9);
	jumpary[0] = "../startup_c/startup.html#LN2";
	idxary[0] = "../startup_c/startup_idx.html";
	jumpary[1] = "../startup_c/_start&0001_vcht1.html";
	idxary[1] = "../startup_c/_start&0001_vcht_idx.html";
	jumpary[2] = "../startup_c/_start&0001_vmod.html";
	idxary[2] = "../startup_c/_start&0001_vmod_idx.html";
	jumpary[3] = null;
	idxary[3] = null;
	jumpary[4] = "../ChartList/project_vblk1.html";
	idxary[4] = "../ChartList/project_vblk_idx.html";
	jumpary[5] = "startup_vblk1.html";
	idxary[5] = "startup_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "startup_vmlt.html";
	idxary[7] = "startup_vmlt_idx.html";
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
	jumpary[5] = "../safety_controller_c/safety_controller_vblk1.html";
	idxary[5] = "../safety_controller_c/safety_controller_vblk_idx.html";
	jumpary[6] = "../ChartList/project_vmlt.html";
	idxary[6] = "../ChartList/project_vmlt_idx.html";
	jumpary[7] = "../safety_controller_c/safety_controller_vmlt.html";
	idxary[7] = "../safety_controller_c/safety_controller_vmlt_idx.html";
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

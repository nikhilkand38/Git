<!--
var S_msg_no = "No related files.";
	function JumpM(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = curdir + reldir + "/" + name + "_vcht_idx.html";
		jumpary[1] = curdir + reldir + "/" + name + "_vcht1.html";
		idxary[2] = curdir + reldir + "/" + name + "_vmod_idx.html";
		jumpary[2] = curdir + reldir + "/" + name + "_vmod.html";
		idxary[3] = null;
		jumpary[3] = null;
		idxary[4] = curdir + "ChartList/project_vblk_idx.html";
		jumpary[4] = curdir + "ChartList/project_vblk1.html";
		idxary[5] = curdir + reldir + "/" + fname + "_vblk_idx.html";
		jumpary[5] = curdir + reldir + "/" + fname + "_vblk1.html";
		idxary[6] = curdir + "ChartList/project_vmlt_idx.html";
		jumpary[6] = curdir + "ChartList/project_vmlt.html";
		idxary[7] = curdir + reldir + "/" + fname + "_vmlt_idx.html";
		jumpary[7] = curdir + reldir + "/" + fname + "_vmlt.html";
		idxary[8] = null;
		jumpary[8] = null;
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpMFN(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = curdir + reldir + "/" + name + "_vcht_idx.html";
		jumpary[1] = curdir + reldir + "/" + name + "_vcht1.html";
		idxary[2] = curdir + reldir + "/" + name + "_vmfn_idx.html";
		jumpary[2] = curdir + reldir + "/" + name + "_vmfn.html";
		idxary[3] = null;
		jumpary[3] = null;
		idxary[4] = curdir + "ChartList/project_vblk_idx.html";
		jumpary[4] = curdir + "ChartList/project_vblk1.html";
		idxary[5] = curdir + reldir + "/" + fname + "_vblk_idx.html";
		jumpary[5] = curdir + reldir + "/" + fname + "_vblk1.html";
		idxary[6] = null;
		jumpary[6] = null;
		idxary[7] = null;
		jumpary[7] = null;
		idxary[8] = null;
		jumpary[8] = null;
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpFNC(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = curdir + reldir + "/" + name + "_vcht_idx.html";
		jumpary[1] = curdir + reldir + "/" + name + "_vcht1.html";
		idxary[2] = curdir + reldir + "/" + name + "_vmod_idx.html";
		jumpary[2] = curdir + reldir + "/" + name + "_vmod.html";
		idxary[3] = null;
		jumpary[3] = null;
		idxary[4] = curdir + "ChartList/project_vblk_idx.html";
		jumpary[4] = curdir + "ChartList/project_vblk1.html";
		idxary[5] = curdir + reldir + "/" + fname + "_vblk_idx.html";
		jumpary[5] = curdir + reldir + "/" + fname + "_vblk1.html";
		idxary[6] = curdir + "ChartList/project_vmlt_idx.html";
		jumpary[6] = curdir + "ChartList/project_vmlt.html";
		idxary[7] = curdir + reldir + "/" + fname + "_vmlt_idx.html";
		jumpary[7] = curdir + reldir + "/" + fname + "_vmlt.html";
		idxary[8] = null;
		jumpary[8] = null;
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpD(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = null;
		jumpary[1] = null;
		idxary[2] = null;
		jumpary[2] = null;
		idxary[3] = curdir + reldir + "/" + name + "_vdat_idx.html";
		jumpary[3] = curdir + reldir + "/" + name + "_vdat.html";
		idxary[4] = null;
		jumpary[4] = null;
		idxary[5] = null;
		jumpary[5] = null;
		idxary[6] = null;
		jumpary[6] = null;
		idxary[7] = null;
		jumpary[7] = null;
		idxary[8] = curdir + "ChartList/project_vdlt_idx.html";
		jumpary[8] = curdir + "ChartList/project_vdlt.html";
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpC(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = null;
		jumpary[1] = null;
		idxary[2] = null;
		jumpary[2] = null;
		idxary[3] = curdir + reldir + "/" + name + "_vcls_idx.html";
		jumpary[3] = curdir + reldir + "/" + name + "_vcls.html";
		idxary[4] = null;
		jumpary[4] = null;
		idxary[5] = null;
		jumpary[5] = null;
		idxary[6] = null;
		jumpary[6] = null;
		idxary[7] = null;
		jumpary[7] = null;
		idxary[8] = curdir + "ChartList/project_vclt_idx.html";
		jumpary[8] = curdir + "ChartList/project_vclt.html";
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpV(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = null;
		jumpary[1] = null;
		idxary[2] = null;
		jumpary[2] = null;
		idxary[3] = null;
		jumpary[3] = null;
		idxary[4] = null;
		jumpary[4] = null;
		idxary[5] = null;
		jumpary[5] = null;
		idxary[6] = null;
		jumpary[6] = null;
		idxary[7] = null;
		jumpary[7] = null;
		idxary[8] = null;
		jumpary[8] = null;
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		if(sp_index==0)
			return;
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpEx(curdir,reldir,fname,name,lnno,index){
		localStorage.setItem("GAIO_CP2_SP_INDEX",index+1);
		Jump(curdir,reldir,fname,name,lnno);
	}
	function Jump(curdir,reldir,fname,name,lnno){
		var idxary = new Array(9);
		var jumpary = new Array(9);
		idxary[0] = curdir + reldir + "/" + fname + "_idx.html";
		jumpary[0] = curdir + reldir + "/" + fname + ".html#LN" + lnno;
		idxary[1] = curdir + reldir + "/" + name + "_vcht_idx.html";
		jumpary[1] = curdir + reldir + "/" + name + "_vcht1.html";
		idxary[2] = curdir + reldir + "/" + name + "_vmod_idx.html";
		jumpary[2] = curdir + reldir + "/" + name + "_vmod.html";
		idxary[3] = curdir + reldir + "/" + name + "_vdat_idx.html";
		jumpary[3] = curdir + reldir + "/" + name + "_vdat.html";
		idxary[4] = curdir + "ChartList/project_vblk_idx.html";
		jumpary[4] = curdir + "ChartList/project_vblk1.html";
		idxary[5] = curdir + reldir + "/" + fname + "_vblk_idx.html";
		jumpary[5] = curdir + reldir + "/" + fname + "_vblk1.html";
		idxary[6] = curdir + "ChartList/project_vmlt_idx.html";
		jumpary[6] = curdir + "ChartList/project_vmlt.html";
		idxary[7] = curdir + reldir + "/" + fname + "_vmlt_idx.html";
		jumpary[7] = curdir + reldir + "/" + fname + "_vmlt.html";
		idxary[8] = curdir + "ChartList/project_vdlt_idx.html";
		jumpary[8] = curdir + "ChartList/project_vdlt.html";
		var sp_index = localStorage.getItem("GAIO_CP2_SP_INDEX");
		if(sp_index==0)
			return;
		for( i=1; i<=9; i++ ){
			if(sp_index==i){
				if( jumpary[i-1] == null )
					alert(S_msg_no);
				else{
					parent.MAIN.location.href=jumpary[i-1];
					parent.INDEX.location.href=idxary[i-1];
				}
				break;
			}
		}
	}
	function JumpEx(curdir,reldir,fname,name,lnno,index){
		localStorage.setItem("GAIO_CP2_SP_INDEX",index+1);
		Jump(curdir,reldir,fname,name,lnno);
	}
	function JumpSrc(curdir,reldir,lnno){
		var idx = curdir + reldir + "_idx.html";
		var jump = curdir + reldir + ".html#LN" + lnno;
		parent.MAIN.location.href=jump;
		parent.INDEX.location.href=idx;
	}
//-->

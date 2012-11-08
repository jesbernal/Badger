<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <meta name='layout' content='main'/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>${grailsApplication.config.projectID} species</title>
    <parameter name="search" value="selected"></parameter>
    <link rel="stylesheet" href="${resource(dir: 'js', file: 'jquery.loadmask.css')}" type="text/css"></link>
    <script src="${resource(dir: 'js', file: 'jquery.loadmask.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/jquery.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/jquery.jqplot.js')}" type="text/javascript"></script>    
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.categoryAxisRenderer.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.pointLabels.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.canvasTextRenderer.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.canvasAxisLabelRenderer.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.highlighter.js')}" type="text/javascript"></script>
    <script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.cursor.min.js')}" type="text/javascript"></script>
  	<script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.logAxisRenderer.js')}" type="text/javascript"></script>
  	<script src="${resource(dir: 'js', file: 'jqplot/plugins/jqplot.barRenderer.min.js')}" type="text/javascript"></script>  	
    <link rel="stylesheet" href="${resource(dir: 'js', file: 'jqplot/jquery.jqplot.css')}" type="text/css"></link>
    <script type="text/javascript"> 
    	$(window).unload(function() {});
    </script>
    
    <% 
  	def jsonAnnoData = funAnnoData.encodeAsJSON(); 
  	def jsonBlastData = blastAnnoData.encodeAsJSON();
  	def jsonGenomeData = genomeInfo.encodeAsJSON();
  	//println jsonAnnoData;
  	%>	
    
    <script type="text/javascript">

    function showSelected(val){
		document.getElementById
		('selectedResult').innerHTML = val;
    }
    $(function() {
		$("[name=toggler]").click(function(){
				$('.toHide').hide();
				$("#blk_"+$(this).val()).show('slow');
				$("#sel_"+$(this).val()).show('fast');
				showSelected($("#sel_"+$(this).val()).val())
		});
    });
    
    function changed(plot_type,params) {
		$("#chart").html('Loading...<img src="${resource(dir: 'images', file: 'spinner.gif')}" />');
		setTimeout(""+plot_type+"('"+params+"')", 2000);
    }
 
    //set the global variable for the plots
    var dlen = [], dcov = [], dgc = [], dcon = [], dcum = [], dcou = [];
    var joinArray = []; 
    var N50 = ${n50}, N90 = ${n90};
    var counter=0;
    var cum = 0;
    var xaxis_label="", yaxis_label="", title_label="", xaxis_type="", yaxis_type="";
    var arraySet;
    function makeArrays(arrayInfo){
    	joinArray = [];
    	$("#chart").text('');
	    //alert(arrayInfo)
	    arraySet = arrayInfo;	    	    
	    if (arrayInfo == 'len_gc'){
		    joinArray = zip([dgc,dlen,dcon,dlen,dgc,dcov]);
		    xaxis_label = "GC";
		    xaxis_type = $.jqplot.LinearAxisRenderer;
		    yaxis_label = "Length";
		    yaxis_type = $.jqplot.LogAxisRenderer;
		    title_label = "Length vs GC";
		    graphDraw()
	    }else if (arrayInfo == 'cov_gc'){
		    joinArray = zip([dgc,dcov,dcon,dlen,dgc,dcov]);
		    xaxis_label = "GC";
		    xaxis_type = $.jqplot.LinearAxisRenderer;
		    yaxis_label = "Coverage";
		    yaxis_type = $.jqplot.LogAxisRenderer;
		    title_label = "Coverage vs GC";
		    graphDraw()
	    }else if (arrayInfo == 'len_cov'){
		    joinArray = zip([dlen,dcov,dcon,dlen,dgc,dcov]);
		    xaxis_label = "Length";
		    xaxis_type = $.jqplot.LinearAxisRenderer;
		    yaxis_label = "Coverage";
		    yaxis_type = $.jqplot.LogAxisRenderer;
		    title_label = "Length vs Coverage";
		    graphDraw()
	    }else if (arrayInfo == 'cum'){          	    	    
		    joinArray = zip([dcou,dcum,dcon,dlen,dgc,dcov]);
		    xaxis_label = "Contigs ranked by size";
		    xaxis_type = $.jqplot.LinearAxisRenderer;
		    yaxis_label = "Cumulative contig length (bp)";
		    yaxis_type = $.jqplot.LinearAxisRenderer;
		    title_label = "Cumulative contig length";
		    cumDraw()
	    }
	    
    }

    function cumDraw(){
       	//alert(joinArray)
	    plot1 = $.jqplot ('chart', [joinArray,N50,N90],{
		 title: title_label,
		 legend: {
		 	show: true,
		 	location: 'se',
		 },  
		 series:[
			 {
				showLine:false,
			 	markerOptions: { size: 1, style:"circle", color:"green"},
			 	//label: 'No annotation',
			 	color: 'green',
			 	showLabel: false,
			 	highlighter: {
					 tooltipAxes: 'yx',
					 yvalues: 5,
					 show: true,
					 sizeAdjust: 7.5,
					 //formatString: "%d"
					 //formatString: ContigData[0].contig_id +" length: " + ContigData[1].length
					 formatString: '<span style="display:none">%s</span>Contig ID: %s<br>Length: %s<br>GC: %.2f<br>Coverage: %.2f'
			
				 },
			 },
			 {
            	showLine:false,
                markerOptions: { size: 20, style:'circle', color:"blue"},
                label: "N50",
                color: "blue",
                highlighter: {
					 tooltipAxes: 'yx',
					 yvalues: 2,
					 show: true,
					 sizeAdjust: 7.5,
					 formatString: '<span style="display:none">%s</span>N50:%s'
			
				 },
             },
             {
            	showLine:false,
                markerOptions: { size: 20, style:'circle', color:"red"},
                label: "N90",
                color: "red",
                highlighter: {
					 tooltipAxes: 'yx',
					 yvalues: 2,
					 show: true,
					 sizeAdjust: 7.5,
					 formatString: '<span style="display:none">%s</span>N90:%s'
			
				 },
             }

		 ],
		 axesDefaults: {
			 labelRenderer: $.jqplot.CanvasAxisLabelRenderer
		 },
		 noDataIndicator: {
		    show: true
		 },
		 axes: {
			xaxis: {
				label: xaxis_label,
				renderer: xaxis_type,
				pad: 0
			},
			yaxis: {
				label: yaxis_label,
				renderer: yaxis_type,
				pad: 0,
				tickOptions: {
					formatString: "%'i"
				}
			}
		 },
		 //seriesColors: pointcolours,
		 highlighter: {
			 tooltipAxes: 'yx',
			 yvalues: 5,
			 show: true,
			 sizeAdjust: 7.5,
			 //formatString: "%d"
			 //formatString: ContigData[0].contig_id +" length: " + ContigData[1].length
			 formatString: '<span style="display:none">%s</span>Contig ID: %s<br>Length: %s<br>GC: %.2f<br>Coverage: %.2f'
	
		 },
		 cursor:{
		 	 show: true,
		 	 zoom:true,
		 	 tooltipLocation:'nw'
		 }
	    });
	    $('.button-reset').click(function() { plot1.resetZoom() });
    }
    
    function graphDraw(){
       	//alert(joinArray)
	    plot1 = $.jqplot ('chart', [joinArray],{
		 title: title_label,
		 legend: {
		 	show: true,
		 	location: 'se',
		 },  
		 series:[
			 {
				showLine:false,
			 	markerOptions: { size: 1, style:"circle", color:"green"},
			 	//label: 'No annotation',
			 	color: 'green',
			 	showLabel: false,
			 	highlighter: {
					 tooltipAxes: 'yx',
					 yvalues: 5,
					 show: true,
					 sizeAdjust: 7.5,
					 //formatString: "%d"
					 //formatString: ContigData[0].contig_id +" length: " + ContigData[1].length
					 formatString: '<span style="display:none">%s</span>Contig ID: %s<br>Length: %s<br>GC: %.2f<br>Coverage: %.2f'
			
				 },
			 },
		 ],
		 axesDefaults: {
			 labelRenderer: $.jqplot.CanvasAxisLabelRenderer
		 },
		 noDataIndicator: {
		    show: true
		 },
		 axes: {
			xaxis: {
				label: xaxis_label,
				renderer: xaxis_type,
				pad: 0
			},
			yaxis: {
				label: yaxis_label,
				renderer: yaxis_type,
				pad: 0,
				tickOptions: {
					formatString: "%'i"
				}
			}
		 },
		 //seriesColors: pointcolours,
		 highlighter: {
			 tooltipAxes: 'yx',
			 yvalues: 5,
			 show: true,
			 sizeAdjust: 7.5,
			 //formatString: "%d"
			 //formatString: ContigData[0].contig_id +" length: " + ContigData[1].length
			 formatString: '<span style="display:none">%s</span>Contig ID: %s<br>Length: %s<br>GC: %.2f<br>Coverage: %.2f'
	
		 },
		 cursor:{
		 	 show: true,
		 	 zoom:true,
		 	 tooltipLocation:'nw'
		 }
	    });
	    $('.button-reset').click(function() { plot1.resetZoom() });
    }
    
    </script>
    <script>
    
    function zip(arrays) {
            return arrays[0].map(function(_,i){
            return arrays.map(function(array){return array[i]})
         });
    }
        
    $(document).ready(function(){       
		//load the jqplot data
		ContigData = ${jsonGenomeData};
		for (var i = 0; i < ContigData.length; i++) {   		 	 
				var hit = ContigData[i];
				counter++;
				cum += hit.length;
				dlen.push(hit.length);
				dcov.push(hit.coverage);
				dgc.push(hit.gc);
				dcon.push(hit.contig_id);
				dcum.push(cum);
				dcou.push(counter);
		}
		//draw the graph on load
		setTimeout("makeArrays('cum')", 1000);
		//add the click data here as adding it at the top causes multiple windows to open
		
		$('#chart').bind('jqplotDataClick',
		function (ev, seriesIndex, pointIndex, data) {
			//alert('series: '+seriesIndex+', point: '+pointIndex+', data: '+data);
			//alert("/search/genome_info?id=${params.Gid}&contig_id=" + data[2])
			window.open("/search/genome_info?Gid=${params.Gid}&contig_id=" + data[2]);
		}
	);      
                    
    
    FunData = ${jsonAnnoData}; 
	var fCount = [], fDb = [], fPer =[];
    
    var FunArray = [];
    for (var i = 0; i < FunData.length; i++) {   		 	 
		var hit = FunData[i];
		if (hit.anno_db == null){
			hit.anno_db = "None"
		}	
		fPer.push((hit.count/"${geneCount}")*100);
		fDb.push(hit.anno_db);
		fCount.push(hit.count)
    }
    FunArray = zip([fCount,fDb]);
    
    var fun_plot = $.jqplot('fun_chart', [FunArray], {
		title: 'Functional annotations', 
  		animate: !$.jqplot.use_excanvas,
  		seriesColors: [ "green"],
        seriesDefaults: {
            renderer:$.jqplot.BarRenderer,
            // Show point labels to the right ('e'ast) of each bar.
            // edgeTolerance of -15 allows labels flow outside the grid
            // up to 15 pixels.  If they flow out more than that, they 
            // will be hidden.
            pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
            // Rotate the bar shadow as if bar is lit from top right.
            shadowAngle: 135,
            // Here's where we tell the chart it is oriented horizontally.
            rendererOptions: {
                barDirection: 'horizontal',
				//shadowDepth: 2,
        		//barMargin: 4,
		    }
        },
        axes: {
        	xaxis: {
				label: 'Number of transcripts with annotation',
			},
            yaxis: {
                renderer: $.jqplot.CategoryAxisRenderer
            }
        }
    });
    $('#fun_chart').bind('jqplotDataClick',
		function (ev, seriesIndex, pointIndex, data) {
			alert('series: '+seriesIndex+', point: '+fDb[pointIndex]+', data: '+data);
			if (fDb[pointIndex] == 'BlastProDom' || fDb[pointIndex] == 'HMMTigr' || fDb[pointIndex] == 'SignalPHMM' || fDb[pointIndex] == 'FPrintScan' || fDb[pointIndex] == 'ProfileScan' || fDb[pointIndex] == 'TMHMM' || fDb[pointIndex] == 'HMMPIR' || fDb[pointIndex] == 'HAMAP' || fDb[pointIndex] == 'HMMPanther' || fDb[pointIndex] == 'HMMPfam' || fDb[pointIndex] == 'PatternScan' || fDb[pointIndex] == 'Gene3D' || fDb[pointIndex] == 'HMMSmart' || fDb[pointIndex] == 'SuperFamily'){
				//window.open("/search/gene_link?annoType=IPR&val="+fDb[pointIndex]+"&id="+data[0]);
			}else{
				//window.open("/search/gene_link?annoType=Functional&val="+fDb[pointIndex]);
			}
		}
	);
    
    BlastData = ${jsonBlastData};    
	var bCount = [], bDb = [], bPer =[];
    
    var BlastArray = [];
    for (var i = 0; i < BlastData.length; i++) {   		 	 
		var hit = BlastData[i];
		if (hit.anno_db == null){
			hit.anno_db = "None"
		}	
		bPer.push((hit.count/"${geneCount}")*100);
		bDb.push(hit.anno_db);
		bCount.push(hit.count)
    }
    BlastArray = zip([bCount,bDb]);
    
	var blast_plot = $.jqplot('blast_chart', [BlastArray], {
		title: 'BLAST homology', 
  		animate: !$.jqplot.use_excanvas,
  		seriesColors: [ "#3366CC"],
        seriesDefaults: {
            renderer:$.jqplot.BarRenderer,
            // Show point labels to the right ('e'ast) of each bar.
            // edgeTolerance of -15 allows labels flow outside the grid
            // up to 15 pixels.  If they flow out more than that, they 
            // will be hidden.
            pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
            // Rotate the bar shadow as if bar is lit from top right.
            shadowAngle: 135,
            // Here's where we tell the chart it is oriented horizontally.
            rendererOptions: {
                barDirection: 'horizontal',
				//shadowDepth: 2,
        		//barMargin: 4,
		    }
        },
        axes: {
        	xaxis: {
				label: 'Number of transcripts with annotation',
			},
            yaxis: {
                renderer: $.jqplot.CategoryAxisRenderer
            }
        }
    });
    
    $('#blast_chart').bind('jqplotDataClick',
		function (ev, seriesIndex, pointIndex, data) {
			alert('series: '+seriesIndex+', point: '+fDb[pointIndex]+', data: '+data);
			//window.open("/search/gene_link?annoType=Blast&val="+bDb[pointIndex]);
		}
	);
	});
    </script>
</head>
<body>
<g:link action="">Search</g:link> > <g:link action="species">Species</g:link> > <i> ${meta.genus} ${meta.species}</i>
<h1><b><i>${meta.genus} ${meta.species}</i></b></h1>

<table width=100%>
      <tr><td width=30%>
			 <h1>Genome:</h1>
			<table>
			<tr><td><b>Span (bp):</b></td><td>${printf("%,d\n",genome_stats.span)}</td></tr>
			 <tr><td><b>Scaffolds:</b></td><td>${printf("%,d\n",genome_stats.num)}</td></tr>
			 <tr><td><b>N50:</b></td><td>${printf("%,d\n",genome_stats.n50)}</td></tr>
			 <tr><td><b>Smallest (bp)</b></td><td>${printf("%,d\n",genome_stats.min)}</td></tr>
			 <tr><td><b>Largest (bp)</b></td><td>${printf("%,d\n",genome_stats.max)}</td></tr>
			 <tr><td><b>GC (%)</b></td><td>${printf("%.4g",genome_stats.gc)}</td></tr>
			 <tr><td><b>Non ATGC (bp)</b></td><td>${printf("%,d\n",genome_stats.nonATGC)}</td></tr>
			  </table>
		</td>
		<td>
			<table>
			<tr>
				<td>
					<input type="button" class="mybuttons" id="process_graph" onclick="changed('makeArrays','cum')" value="Cumulative length"/>
					<input type="button" class="mybuttons" id="process_graph" onclick="changed('makeArrays','len_gc')" value="Length vs GC"/>
					<g:each var="f" in="${meta.files}">
      					<g:if test="${f.file_type == 'Genome'}">
      						<!--${f.file_type} ${f.file_name} ${f.cov}-->
      						<g:if test="${f.cov == 'y'}">
      							<input type="button" class="mybuttons" id="process_graph" onclick="changed('makeArrays','cov_gc')" value="Coverage vs GC"/>
								<input type="button" class="mybuttons" id="process_graph" onclick="changed('makeArrays','len_cov')" value="Length vs Coverage"/>
      						</g:if>
      					</g:if>
   					</g:each>
				</td>
			</tr>
			<tr><td><p>Zoom in by dragging around an area. Reset by double clicking or clicking <font STYLE="cursor: pointer" color="green" class="button-reset">here</font></td></tr>
		 	</table>   
		 
		  	<div id="chart" class="jqplot-target" style="height: 300px; width: 100%; position: center;">Loading...<img src="${resource(dir: 'images', file: 'spinner.gif')}"</div>
		 
		 </td></tr>
		 <tr><td>
		 <h1>Genes:</h1>
		 <table>
		 <tr><td><b>Number genes</b></td><td>${printf("%,d\n",gene_stats.genenum)}</td></tr>
		 <tr><td><b>Number transcripts</b></td><td>${printf("%,d\n",gene_stats.mrnanum)}</td></tr>
		 <tr><td><b>Frequency (genes per Kb)</b></td><td>${printf("%.4g",(badger.GeneInfo.count()/genome_stats.span)*1000)}</td></tr>
		 <tr><td><b>Mean transcript length (bp)</b></td><td>${printf("%,d\n",gene_stats.mean)}</td></tr>
		 <tr><td><b>Smallest (bp)</b></td><td>${printf("%,d\n",gene_stats.min)}</td></tr>
		 <tr><td><b>Largest (bp)</b></td><td>${printf("%,d\n",gene_stats.max)}</td></tr>
		 <tr><td><b>GC (%)</b></td><td>${printf("%.4g",gene_stats.gc)}</td></tr>
		 <tr><td><b>Non ATGC (bp)</b></td><td>${printf("%,d\n",gene_stats.nonATGC)}</td></tr>
		 </table>
	 </td><td>
	 	<br>
 		<div id="blast_chart" class="jqplot-target" style="height: 200px; width: 100%; position: center;"></div>
 		<br>
 		<div id="fun_chart" class="jqplot-target" style="height: 250px; width: 100%; position: center;"></div>
 	 </td></tr>
 </table>
  
  <g:if test = "${meta}">
  <div id="content">
  	<g:form action="gene_search_results">	
  	<h2><b>Select a data set</b></h2>
	<select name="dataSelect">
		<g:each var="f" in="${meta.files}">
			<g:if test="${f.file_type == 'Genes'}">
				<option value=${f.id}>${meta.genus} ${meta.species}: ${f.file_type} (${f.file_version}) - ${f.file_name}
			</g:if>
		</g:each>
	</select>	
		<div id = "showAnno">
		<table>
		<tr><td>
		<h1>Choose an annotation:</h1>
		<g:each var="t" in="${meta.files.anno}">
			<g:if test="${'blast' in t.type}">
				<label><input name="toggler" type="radio" id="blast" checked="checked" value="1"> 1. BLAST homology</label><br>
				<div class="toHide" id="blk_1" style="height:150;width:200px;overflow:auto;border:3px solid green;display:none">
					<g:each var="a" in="${t}">
						<g:if test="${a.type == 'blast'}">
							<label><input type="checkbox" checked="yes" name="blastAnno" value="${a.source}" /> ${a.source}</label><br>
						</g:if>
					</g:each> 
				</div> 
			</g:if>
			<g:if test="${'fun' in t.type}">
				<label><input name="toggler" type="radio" id="anno" value="2"> 2. Functional annotation </label><br>  			
				<div class="toHide" id="blk_2" style="height:150;width:200px;overflow:auto;border:3px solid green;display:none">
					<g:each var="a" in="${t}">
						<g:if test="${a.type == 'fun'}">
							<label><input type="checkbox" checked="yes" name="funAnno" value="${a.source}" /> ${a.source}</label><br>
						</g:if>
					</g:each>	
				</div> 
			</g:if>
			<g:if test="${'ipr' in t.type}">
				<label><input name="toggler" type="radio" id="ipr" value="3"> 3. InterPro domains</label><br>
				<div class="toHide" id="blk_3" style="height:150;width:200px;overflow:auto;border:3px solid green;display:none">
					<label><input type="checkbox" checked="yes" name="iprAnno" value="HMMPanther" /> PANTHER <a href="http://www.pantherdb.org/" style="text-decoration:none" target="_blank">?</a></label><br>
					<label><input type="checkbox" checked="yes" name="iprAnno" value="BlastProDom" /> ProDom <a href="http://prodom.prabi.fr/prodom/current/html/home.php" style="text-decoration:none" target="_blank">?</a></label><br>
					<label><input type="checkbox" checked="yes" name="iprAnno" value="Gene3D" /> Gene3D <a href="http://gene3d.biochem.ucl.ac.uk/Gene3D/" style="text-decoration:none" target="_blank">?</a></label><br>
					<label><input type="checkbox" checked="yes" name="iprAnno" value="HMMSmart" /> SMART <a href="http://smart.embl-heidelberg.de/" style="text-decoration:none" target="_blank">?</a></label><br>
					<label><input type="checkbox" checked="yes" name="iprAnno" value="HMMPfam" /> Pfam <a href="http://pfam.sanger.ac.uk/" style="text-decoration:none" target="_blank">?</a></label><br>
					<label><input type="checkbox" checked="yes" name="iprAnno" value="HMMTigr" /> TIGRFAMs <a href="http://www.jcvi.org/cgi-bin/tigrfams/index.cgi" style="text-decoration:none" target="_blank">?</a></label><br>
				</div> 
			</g:if>
		</g:each>
	
		<td>  
		<h1>Choose what to search:</h1>
		<select class="toHide" name = "tableSelect_1" id ="sel_1" onChange='showSelected(this.value)'>
		  <option value="e.g. ATPase">Description</option>
		  <option value="e.g. 215283796 or P31409">ID</option>    
		</select>
		<select class="toHide" name = "tableSelect_2" id ="sel_2" onChange='showSelected(this.value)'>
		  <option value="e.g. Calcium-transportingATPase">Description</option>
		  <option value="e.g. GO:0008094 or 3.6.3.8 or K02147">ID</option>    
		</select>
		<select class="toHide" name = "tableSelect_3" id ="sel_3" onChange='showSelected(this.value)'>
		  <option value="e.g. Vacuolar (H+)-ATPase G subunit">Description</option>
		  <option value="e.g. IPR023298 or PF01813">ID</option>    
		</select>
		  </td>
		  
		  <td>
		<h1>Enter a search term:</h1>
		<div id='selectedResult'></div>
		<g:textField name="searchId"  size="30"/>
		<input type="hidden" name="Gid" value="${params.Gid}">
		<input class="mybuttons" type="button" value="Search" id="process" onclick="submit()" >
		</g:form>
		 </td>
	  </tr>
	   </table>
	   <br>
	   </div>
	   
	   <g:if test = "${meta}">
  	 	<table>
  	 		<tr><td width=15%><b>Data type</b></td><td><b>Version</b></td><td><b>Description</b></td><td><b>Number</b></td></tr>
  	 		<g:each var="f" in="${meta.files}">
  	 			<tr><td>${f.file_type}</td><td>${f.file_version}</td><td>${f.description}</td><td>${stats."${f.file_type}"}</td></tr>
  	 		</g:each>
  	 	</table>
  	 </g:if>
  	 <g:else>
  	 	<h2>There are no species in the database at present, please add some</h2>
  	 </g:else>
	   
	</g:if>
	<g:else>
		<h2>There are no annotations for this species</h2>
	</g:else>
   
   <script>
          $(document).ready(function(){
            $('.toHide').hide();
            $("#blk_1").show('slow');
	    $("#sel_1").show('fast');
	    showSelected($("#sel_1").val())
	    
	    $("#contig_attribute").show('slow');
	    
            $("#process").bind("click", function () {
              $("#content").mask("Searching the database...");
            });
				
            $("#cancel").bind("click", function () {
		$("#content").unmask();
            });               
          });
        </script>
        
</body>
</html>
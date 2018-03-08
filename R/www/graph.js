var nodes = {};

shinyjs.paintGraph = function(sifParse){
 
  var nodes = []
	var links = [];
  	var nodeName = [];
  	var nodeType = [];
  	for(i=0; i<sifParse[0].nodos.length; i++){
    	nodeName.push(sifParse[0].nodos[i]);
    	nodeType.push(sifParse[0].tipoNodo[i]);
  	}
  
  	for(i=0; i<sifParse[0].source.length; i++){
    	link={source: sifParse[0].source[i], target:sifParse[0].target[i], type:sifParse[0].tipoLink[i]};
    	links.push(link)
  	}

  	links.forEach(function(link) {
    	link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
    	link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
  	});
  	var width = 1500,
		height = 700,
		radius = 6;

  	var force = d3.layout.force()
		.nodes(d3.values(nodes))
		.links(links)
		.size([width, height])
		.linkDistance(80)
		.charge(-200)
		.on("tick", tick)
		.gravity(0.07)
		.start();

	var drag = force.drag()
		.on("dragstart", dragstart);

	var svg = d3.select(".paintGraph").append("svg")
	  	.attr("width", width)
	 	.attr("height", height);
	  
	  
	svg.append("defs").selectAll("marker")
		.data(["controlOf","outputLink"])
		.enter().append("marker")
	  	.attr("id", function(d) { return d; })
	  	.attr("viewBox", "0 -5 10 10")
	  	.attr("refX", 15)
	  	.attr("refY", -1)
	  	.attr("markerWidth", 6)
	  	.attr("markerHeight", 6)
	  	.attr("orient", "auto")
		.append("path")
	  	.attr("d", "M0,-5L10,0L0,5");
	  
	var path = svg.append("g").selectAll("path")
		.data(force.links())
		.enter().append("line")
		.attr("class", function(d) { return "link " + d.type; })
		.attr("marker-end", function(d) { return "url(#" + d.type + ")"; });


	var rectSet = []
 	var circleSet = []
 	var circleSetC = []
  	var circleSMSetC = []
  	var circleSMSet = []
	  
	force.nodes().forEach(function(n){
	    i = nodeName.indexOf(n.name);
	    if(nodeType[i]=="NProt"){
	      circleSet.push(n);
	    }else if(nodeType[i]=="NProtC"){
	      circleSetC.push(n);
	    }else if(nodeType[i]=="control"){
	      rectSet.push(n);
	    }else if(nodeType[i]=="NSM"){
	      circleSMSet.push(n);
	    }else if(nodeType[i]=="NSMC"){
	      circleSetC.push(n);
	    }else{
	    	circleSet.push(n);
	    }
	});
	
	console.log(circleSet)

	var control = svg.append("g").selectAll("rect")
	  	.data(rectSet)
		.enter().append("rect")
		.attr("width", 20)
	  	.attr("height", 20)
	  	.attr("class",function(d){
	  		var type = "";
	  		if(d.name.includes("expression")){
	  			type = "expression";
	  		}else if(d.name.includes("in_complexLink")){
	  			type = "in_complexLink";
	  		}
	  		return "control " + type})
	  	.on("dblclick", dblclick)
	  	.call(force.drag);

	
		var circleSM = svg.append("g").selectAll("circle")
	  	.data(circleSMSet)
  		.enter().append("circle")
    	.attr("r", radius)
		.attr("class","circleSM")
		.on("mouseover", mouseover)
    	.on("mouseout", mouseout)
    	.on("dblclick", dblclick)
    	.call(force.drag);
	
	
	  
	var circle = svg.append("g").selectAll("circle")
	  	.data(circleSet)
  		.enter().append("circle")
    	.attr("r", radius)
    	.attr("class",function(d){
    		if(d.name != null){
	    		var styleType = "";
	    		if (d.name.includes("_P")) {
	    			styleType="phosphorylation";
	    		}else if(d.name.includes("_chem_Affects")){
	    			styleType="chem_Affects"
	    		}else if(d.name.includes("_STATE_CHANGE")){
	    			styleType="state_change"
	    		}
	    		return "circle " + styleType;
    		}
    		
    	})
    	.on("mouseover", mouseover)
    	.on("mouseout", mouseout)
    	.on("dblclick", dblclick)
    	.call(force.drag);

	var circleC = svg.append("g").selectAll("circle")
  	.data(circleSetC)
		.enter().append("circle")
	.attr("r", radius)
	.attr("class",function(d){
    		return "circleC";
	})
	.on("mouseover", mouseover)
	.on("mouseout", mouseout)
	.on("dblclick", dblclick)
	.call(force.drag);
	  
  	var text = svg.append("g").selectAll("text")
	  	.data(force.nodes())
		.enter().append("text")
	  	.attr("x", 8)
	  	.attr("y", ".31em")
	  	.text(function(d) { 
	  		if(d.name != null){

	    	var name = d.name;

		    if(d.name.includes("control")){
    	  		name="";
		    }else if(d.name.includes("_")){
		    	name=d.name.split("_")[0];
		    }
		    return name; }});
	   
  	function tick() {
		path.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
		control.attr("transform", transform);
		circle.attr("transform", transform);
		circleC.attr("transform", transform);
		circleSM.attr("transform", transform);
		text.attr("transform", transform);
  	}
	  
  	function transform(d) {
  		
		return "translate(" + Math.max(radius, Math.min(width - radius, d.x)) + "," + Math.max(radius, Math.min(height - radius, d.y)) + ")";
  	}

  	function mouseover() {
	  	d3.select(this).transition()
      		.duration(750)
	      	.attr("r", 16);
	}

	function mouseout() {
	  	d3.select(this).transition()
	      	.duration(750)
	      	.attr("r", 6);
	}


	function dblclick(d) {
   		d3.select(this).classed("fixed", d.fixed = false);
	}

	function dragstart(d) {
    	d3.select(this).classed("fixed", d.fixed = true);
	}
}
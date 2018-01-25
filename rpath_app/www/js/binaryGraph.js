var links = [];


var parseSif = function(sif){
  for(i = 0; i<sif[0].PARTICIPANT_A.length; i++){
    link = {source: sif[0].PARTICIPANT_A[i], target: sif[0].PARTICIPANT_B[i], type: sif[0].INTERACTION_TYPE[i]}
    links.push(link)
  }
}

shinyjs.paintBinaryGraph = function(sif){
  parseSif(sif);
  var nodes = {};

  links.forEach(function(link) {
  link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
  link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
});

  var width = 1500,
      height = 700;

  var force = d3.layout.force()
      .nodes(d3.values(nodes))
      .links(links)
      .size([width, height])
      .linkDistance(70)
      .charge(-400)
      .gravity(0.07)
      .on("tick", tick)
      .start();
  var drag = force.drag()
    .on("dragstart", dragstart);

  var svg = d3.select(".paintGraph").append("svg")
      .attr("width", width)
      .attr("height", height);

  var link = svg.selectAll(".link")
      .data(force.links())
    .enter().append("line")
      .attr("class", "link");

  var node = svg.selectAll(".node")
      .data(force.nodes())
    .enter().append("g")
      .attr("class", "node")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("dblclick", dblclick)
      .call(drag);
  radius = 12;
  node.append("circle")
      .attr("r", radius);

  node.append("text")
      .attr("x", 12)
      .attr("dy", ".35em")
      .text(function(d) { return d.name; });

  function tick() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node
        .attr("transform", transform);
  }
  function transform(d) {
      
    return "translate(" + Math.max(radius, Math.min(width - radius, d.x)) + "," + Math.max(radius, Math.min(height - radius, d.y)) + ")";
    }

  function mouseover() {
    d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 16);
  }

  function mouseout() {
    d3.select(this).select("circle").transition()
        .duration(750)
        .attr("r", 8);
  }

  function dblclick(d) {
   d3.select(this).classed("fixed", d.fixed = false);
  }

  function dragstart(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }
}
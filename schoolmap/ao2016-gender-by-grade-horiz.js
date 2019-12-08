var svg2Box = d3.select("#gbg")

var margin2 = {top: 20, right: 20, bottom: 30, left: 50},
    width2 = svg2Box.attr("width") - margin2.left - margin2.right,
    height2 = svg2Box.attr("height") - margin2.top - margin2.bottom;

var y2 = d3.scale.ordinal()
    .rangeRoundBands([height2, 0], .2);

var x2 = d3.scale.linear()
    .rangeRound([0, width2]);

// var color2 = d3.scale.ordinal()
//     .range(["#98abc5", "#7b6888", "#a05d56", "#ff8c00"]);

var color2 = d3.scale.ordinal()
    .range(["#1F8A70", "#004358"]);

var yAxis2 = d3.svg.axis()
    .scale(y2)
    .orient("left");

var xAxis2 = d3.svg.axis()
    .scale(x2)
    .orient("bottom")
    .tickFormat(d3.format(".2s"));

var svg2 = d3.select("#gbg")
    .attr("width", width2 + margin2.left + margin2.right)
    .attr("height", height2 + margin2.top + margin2.bottom)
    .append("g")
    .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");

d3.csv("ao2016-gender-by-grade.csv", function(error, data) {
    if (error) throw error;

    color2.domain(d3.keys(data[0]).filter(function(key) { return key !== "State"; }));

    data.forEach(function(d) {
        var y0 = 0;
        d.ages = color2.domain().map(function(name) { return {name: name, y0: y0, y1: y0 += +d[name]}; });
        d.total = d.ages[d.ages.length - 1].y1;
    });

//    data.sort(function(a, b) { return b.total - a.total; });

    y2.domain(data.map(function(d) { return d.State; }));
    x2.domain([0, d3.max(data, function(d) { return d.total; })]);

    svg2.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height2 + ")")
        .call(xAxis2);

    svg2.append("g")
        .attr("class", "y axis")
        .call(yAxis2)
        .append("text")
//        .attr("transform", "rotate(-90)")
        .attr("transform", "translate(70,-15)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Dalībn. sk.");

    var state = svg2.selectAll(".state")
        .data(data)
        .enter().append("g")
        .attr("class", "g")
        .attr("transform", function(d) { return "translate(0," + y2(d.State) + ")"; });

    state.selectAll("rect")
        .data(function(d) { return d.ages; })
        .enter().append("rect")
        .attr("height", y2.rangeBand())
        .attr("x", function(d) { return x2(d.y0); })
        .attr("width", function(d) { return x(d.y1) - x(d.y0); })
        .style("fill", function(d) { return color2(d.name); });

    for (var i = 0; i < data.length; i++) {
        svg2.append("rect")
            .attr("class", "bumbum")
            .attr("transform", "translate(0," + y2(data[i].State) + ")")
            .attr("height", y2.rangeBand())
            .attr("x", 0)
            .attr("width", x2(data[i].total))
            .append("title")
            .text("Meitenes: " + data[i].Female + ", Zēni: " + data[i].Male);
    }


    for (var i = 1; i <= 7; i++) {
        if (i < 7) {
            svg2.append("line")
                .attr("x1", x2(x2.ticks(7)[i]))
                .attr("y1", 0)
                .attr("x2", x2(x2.ticks(7)[i]))
                .attr("y2", height2)
                .attr("style", "stroke:rgb(139,0,0);stroke-width:1;stroke-dasharray: 10 5;");
        } else {
            svg2.append("line")
                .attr("x1", x2(x2.ticks(7)[i]))
                .attr("y1", height2/3)
                .attr("x2", x2(x2.ticks(7)[i]))
                .attr("y2", height2)
                .attr("style", "stroke:rgb(139,0,0);stroke-width:1;stroke-dasharray: 10 5;");

        }
    }



    var legend = svg2.selectAll(".legend")
        .data(color2.domain().slice().reverse())
        .enter().append("g")
        .attr("class", "legend")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("x", width2 - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color2);

    legend.append("text")
        .attr("x", width2 - 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text(function(d) { return d; });

});

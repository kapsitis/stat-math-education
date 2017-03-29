var svg3Box = d3.select("#lbg")

var margin3 = {top: 20, right: 20, bottom: 30, left: 50},
    width3 = svg3Box.attr("width") - margin3.left - margin3.right,
    height3 = svg3Box.attr("height") - margin3.top - margin3.bottom;

var y3 = d3.scale.ordinal()
    .rangeRoundBands([height3, 0], .3);

var x3 = d3.scale.linear()
    .rangeRound([0, width3]);

// var color2 = d3.scale.ordinal()
//     .range(["#98abc5", "#7b6888", "#a05d56", "#ff8c00"]);

var color3 = d3.scale.ordinal()
    .range(["#FF0000", "#5DB063"]);

var yAxis3 = d3.svg.axis()
    .scale(y3)
    .orient("left");

var xAxis3 = d3.svg.axis()
    .scale(x3)
    .orient("bottom")
    .tickFormat(d3.format(".2s"));

var svg3 = d3.select("#lbg")
    .attr("width", width3 + margin3.left + margin3.right)
    .attr("height", height3 + margin3.top + margin3.bottom)
    .append("g")
    .attr("transform", "translate(" + margin3.left + "," + margin3.top + ")");

d3.csv("ao2016-language-by-grade.csv", function(error, data) {
    if (error) throw error;

    color3.domain(d3.keys(data[0]).filter(function(key) { return key !== "State"; }));

    data.forEach(function(d) {
        var y0 = 0;
        d.ages = color3.domain().map(function(name) { return {name: name, y0: y0, y1: y0 += +d[name]}; });
        d.total = d.ages[d.ages.length - 1].y1;
    });

//    data.sort(function(a, b) { return b.total - a.total; });

    y3.domain(data.map(function(d) { return d.State; }));
    x3.domain([0, d3.max(data, function(d) { return d.total; })]);

    svg3.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height3 + ")")
        .call(xAxis3);

    svg3.append("g")
        .attr("class", "y axis")
        .call(yAxis3)
        .append("text")
//        .attr("transform", "rotate(-90)")
        .attr("transform", "translate(70,-15)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Dalībn. sk.");

    var state = svg3.selectAll(".state")
        .data(data)
        .enter().append("g")
        .attr("class", "g")
        .attr("transform", function(d) { return "translate(0," + y3(d.State) + ")"; });

    state.selectAll("rect")
        .data(function(d) { return d.ages; })
        .enter().append("rect")
        .attr("height", y3.rangeBand())
        .attr("x", function(d) { return x3(d.y0); })
        .attr("width", function(d) { return x3(d.y1) - x3(d.y0); })
        .style("fill", function(d) { return color3(d.name); });


    var langPercent = [28.05, 28.77, 27.67, 27.10, 27.13, 26.55, 27.25, 25.70];
    var langPercentStr = ["28.05", "28.77", "27.67", "27.10", "27.13", "26.55", "27.25", "25.70"];
    var dxx = y3.rangeBand()/5;
    var dyy = y3.rangeBand()/5*1.732;

    for (var i = 0; i < data.length; i++) {
        svg3.append("rect")
            .attr("class", "bumbum")
            .attr("transform", "translate(0," + y3(data[i].State) + ")")
            .attr("height", y3.rangeBand())
            .attr("x", 0)
            .attr("width", x3(data[i].total))
            .append("title")
            .text("Latviešu: " + data[i]["Latviešu"] + ", Krievu: " + data[i]["Krievu"]
                + ", (skolēnu īpatsvars ar krievu mācību valodu: " + langPercentStr[i] + "%)");
        var xx0 = x3((langPercent[i]/100)*data[i].total);
        var yy0 = y3(data[i].State) + y3.rangeBand() - (dyy - dxx);

        svg3.append("polygon")
            .attr("points", xx0 + "," + yy0 + " " + (xx0 - dxx) + "," + (yy0 + dyy) + " " + (xx0 + dxx) + "," + (yy0 + dyy))
            .attr("fill","darkblue");


    }


    for (var i = 1; i <= 7; i++) {
        if (i < 7) {
            svg3.append("line")
                .attr("x1", x3(x3.ticks(7)[i]))
                .attr("y1", 0)
                .attr("x2", x3(x3.ticks(7)[i]))
                .attr("y2", height3)
                .attr("style", "stroke:rgb(139,0,0);stroke-width:1;stroke-dasharray: 10 5;");
        } else {
            svg3.append("line")
                .attr("x1", x3(x3.ticks(7)[i]))
                .attr("y1", height3/3)
                .attr("x2", x3(x3.ticks(7)[i]))
                .attr("y2", height3)
                .attr("style", "stroke:rgb(139,0,0);stroke-width:1;stroke-dasharray: 10 5;");

        }
    }



    var legend = svg3.selectAll(".legend")
        .data(color3.domain().slice().reverse())
        .enter().append("g")
        .attr("class", "legend")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("x", width3 - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color3);


    legend.append("text")
        .attr("x", width3 - 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text(function(d) { return d; });

    var legx0 = width3 - 9;
    var legy0 = 45;
    svg3.append("polygon")
        .attr("points", legx0 + "," + legy0 + " " + (legx0 - dxx) + "," + (legy0 + dyy) + " " + (legx0 + dxx) + "," + (legy0 + dyy))
        .attr("fill", "darkblue");

    svg3.append("text")
        .attr("x", width3 - 24)
        .attr("y", 49.5)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text("Krievu");
    svg3.append("text")
        .attr("x", width3 - 24)
        .attr("y", 49.5 + 18)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text("skolēnu");
    svg3.append("text")
        .attr("x", width3 - 24)
        .attr("y", 49.5 + 36)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text("īpatsvars");


});

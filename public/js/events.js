$(function() {

    Morris.Donut({
        element: 'morris-donut-chart',
        data: [{
            label: "Download Sales",
            value: 12
        }, {
            label: "In-Store Sales",
            value: 30
        }, {
            label: "Mail-Order Sales",
            value: 20
        }],
        resize: true
    });

    Morris.Bar({
        element: 'morris-bar-chart',
        data: [{
	    y: '00:00',
            a: 100,
            b: 90
        }, {
		y: '01:00',
            a: 75,
            b: 65
        }, {
		y: '02:00',
            a: 50,
            b: 40
        }, {
		y: '03:00',
            a: 75,
            b: 65
        }, {
		y: '04:00',
            a: 50,
            b: 40
        }, {
		y: '05:00',
            a: 75,
            b: 65
        }, {
		y: '06:00',
            a: 100,
            b: 90
	}, {
		y: '07:00',
	    a: 10,
	    b: 20
   }, {
                y: '08:00',
            a: 10,
            b: 20

   }, {
                y: '09:00',
            a: 10,
            b: 20

   }, {
                y: '10:00',
            a: 10,
            b: 20

   }, {
                y: '11:00',
            a: 10,
            b: 20

   }, {
                y: '12:00',
            a: 10,
            b: 20

   }, {
                y: '13:00',
            a: 10,
            b: 20

   }, {
                y: '14:00',
            a: 10,
            b: 20

   }, {
                y: '15:00',
            a: 10,
            b: 20

   }, {
                y: '16:00',
            a: 10,
            b: 20

   }, {
                y: '17:00',
            a: 10,
            b: 20
        }],
        xkey: 'y',
        ykeys: ['a', 'b'],
        labels: ['Series A', 'Series B'],
        hideHover: 'auto',
        resize: true
    });

});

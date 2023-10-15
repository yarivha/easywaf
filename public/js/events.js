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

    Morris.Donut({
        element: 'morris-donut2-chart',
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
            a: 50,
        }, {
	    y: '01:00',
            a: 75,
        }, {
	    y: '02:00',
            a: 50,
        }, {
	    y: '03:00',
            a: 75,
        }, {
	    y: '04:00',
            a: 50,
        }, {
	    y: '05:00',
            a: 75,
        }, {
	    y: '06:00',
            a: 100,
	}, {
	    y: '07:00',
	    a: 10,
   }, {
            y: '08:00',
            a: 10,
   }, {
            y: '09:00',
            a: 10,
   }, {
            y: '10:00',
            a: 10,
   }, {
            y: '11:00',
            a: 10,
   }, {
            y: '12:00',
            a: 10,
   }, {
            y: '13:00',
            a: 10,
   }, {
            y: '14:00',
            a: 10,
   }, {
            y: '15:00',
            a: 10,
   }, {
            y: '16:00',
            a: 10,
   }, {
            y: '17:00',
            a: 10,
   }, {
            y: '18:00',
            a: 10,
}, {
            y: '19:00',
            a: 10,
}, {
            y: '20:00',
            a: 10,
}, {
            y: '21:00',
            a: 10,
}, {
            y: '22:00',
            a: 10,
}, {
            y: '23:00',
            a: 10,
        }],
        xkey: 'y',
        ykeys: ['a'],
        labels: ['Events'],
        hideHover: 'auto',
        resize: true
    });

});

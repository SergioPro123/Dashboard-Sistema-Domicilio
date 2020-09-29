/*************************************************************************************/
// -->Template Name: Bootstrap Press Admin
// -->Author: Themedesigner
// -->Email: niravjoshi87@gmail.com
// -->File: datatable_basic_init
/*************************************************************************************/

/****************************************
 *       Basic Table                   *
 ****************************************/
$('#zero_config').DataTable({
    language: {
        search: 'Buscar',
        emptyTable: 'No hay datos disponibles en la tabla',
        info: 'Visualizando _START_ a _END_ de _TOTAL_ registros',
        infoEmpty: 'Visualizando 0 a 0 de 0 registros',
        infoFiltered: '(Filtrado de _MAX_ registros totales)',
        infoPostFix: '',
        thousands: ',',
        lengthMenu: 'Visualizar _MENU_ registros',
        loadingRecords: 'Cargando...',
        processing: 'Procesando...',
        zeroRecords: 'No se encontraron registros coincidentes',
        paginate: {
            first: 'Primero',
            last: 'Último',
            next: '>',
            previous: '<',
        },
        aria: {
            sortAscending: ': activar para ordenar la columna ascendente',
            sortDescending: ': activar para ordenar la columna descendente',
        },
    },
});

/****************************************
 *       Default Order Table           *
 ****************************************/
$('#default_order').DataTable({
    order: [[3, 'desc']],
});

/****************************************
 *       Multi-column Order Table      *
 ****************************************/
$('#multi_col_order').DataTable({
    columnDefs: [
        {
            targets: [0],
            orderData: [0, 1],
        },
        {
            targets: [1],
            orderData: [1, 0],
        },
        {
            targets: [4],
            orderData: [4, 0],
        },
    ],
});

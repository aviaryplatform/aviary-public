/**
 * Search Page operations
 *
 * @author Furqan Wasi<furqan@weareavp.com, furqan.wasi66@gmail.com>
 *
 * SearchPage Handler
 *
 * @returns {SearchPage}
 */

var selfRBE;

function ResourceBulkFileEdit(ids_session_raw) {
    selfRBE = this;
    selfRBE.app_helper = {};

    selfRBE.ids_session_raw = ids_session_raw;

    /**
     *
     * @returns {none}
     */
    this.initialize = function () {
        selfRBE.app_helper = new App();
        if (typeof selfRBE.ids_session == 'undefined' || selfRBE.ids_session.length <= 0) {
            selfRBE.ids_session = [];
        }

        if (selfRBE.ids_session_raw && selfRBE.ids_session_raw.length > 0) {
            selfRBE.ids_session = selfRBE.ids_session_raw.replace(/&quot;/g, '"');
            selfRBE.ids_session = JSON.parse(selfRBE.ids_session);
        }
        selfRBE.re_init_bulk();
    };

    this.re_init_bulk = function () {
        bindings();
        if (typeof $('.bulk_operation')[0] !== 'undefined') {
            var selectize = $('.bulk_operation')[0].selectize;
            if (typeof selectize != 'undefined') {
                update_bulk_edit_view(selectize.getValue());
            }
        }
        selfRBE.set_checkbox_bulk(selfRBE.ids_session);
    };

    /**
     *
     * @param response
     * @param container
     * @param requestData
     */
    this.bulk_resource_list_clear_all = function (response, container, requestData) {
        location.reload();
    };

    /**
     *
     * @param response
     * @param container
     * @param requestData
     */
    this.handlecallback = function (response, container, requestData) {

        try {
            eval('this.' + requestData.action + '(response,container,requestData)');
        } catch (err) {
            try {
                eval('this.' + response[0].action + '(response,container,requestData)');
            } catch (err) {
                try {
                    eval('this.' + requestData.action + '(response,container,requestData)');
                } catch (err) {
                    location.reload();
                }
            }
        }
    };

    this.bulk_edit_operation = function (response, container) {
        jsMessages('success', response[0]['message']);
        $('.bulk-edit-review-modal').modal('hide');
        $('#num_of_rec_updated').html(selfRBE.ids_session.length);
        setTimeout(function () {
            location.reload();
        }, 3000);
    };


    /**
     * Bind all elements
     *
     * @returns {undefined}
     */
    const bindings = function () {

        $('#collection_resource_datatable_filter input').on('keyup', function () {
            $('.export_btn_resource').attr('href', $('.export_btn_resource').data('url') + '?search[value]=' + $(this).val());
        });
        $('.bulk-edit-submit').unbind('click');
        $('.bulk-edit-submit').on('click', function () {
            selfRBE.app_helper.classAction($(this).data('url'), {
                action: 'fetch_bulk_edit_resource_list',
                type: 'collection_resource_file'
            }, 'HTML', 'GET', '', selfRBE);
        });
        bulk_form_submit();
        bulk_option_selection();
        binding_single_checkbox();
        binding_select_all();
        $('.bluk-edit-btn').on('click', function () {
            if (selfRBE.ids_session.length <= 0) {
                jsMessages('danger', 'Please select resources before doing bulk operations.');
            } else {
                $('.bulk-edit-modal').modal();
            }
        });
    };

    this.fetch_bulk_edit_resource_list = function (response) {
        $('.bulk-edit-review-content-resource-file').html('');
        $('.review_resources_file_bulk').DataTable().destroy();
        $('.bulk-edit-review-content-resource-file').html(response);
        $('.review_resources_file_bulk').DataTable({
            pageLength: 10,
            bLengthChange: false,
            destroy: true,
            bInfo: true,
        });
    };

    /**
     * Bulk Form Submit
     */
    const bulk_form_submit = function () {
        $('#bulk_edit_form').unbind('submit');
        $('#bulk_edit_form').on('submit', function (e) {
            var form_data = $(this).serialize();

            $('.loadingtextCus').html('<strong class="font-size-21px">Please Do not close this window. Closing this window will disturb this process. This process might take little longer. <br/> <span id="num_of_rec_updated">0</span> of record updated out of  ' + selfRBE.ids_session.length + '</strong>');
            selfRBE.app_helper.show_loader_text();
            setTimeout(function () {
                get_progress_status();
            }, 5000);
            selfRBE.app_helper.classAction($('#bulk_edit_form').attr('action'), form_data, 'JSON', 'POST', '', selfRBE);
            e.preventDefault();
        });
    };

    const get_progress_status = function () {
        selfRBE.app_helper.classAction($('#url_form_progress').data('url'), {
            action: 'update_progress',
            bulk_edit_type_of_bulk_operation: $('.bulk_operation_collection_file').val(),
            access_type: $('.change_status_select_option').val(),
            is_downloadable: $('.change_downloadable_status_option').val(),
            ids: selfRBE.ids_session
        }, 'JSON', 'GET', '', selfRBE, false);
    };

    const bulk_option_selection = function () {
            $('.bulk_operation').change(function () {
                update_bulk_edit_view($(this).val());
            });
        }
    ;

    const binding_select_all = function () {
        $('.select_all_checkbox_resources').unbind('click');
        $('.select_all_checkbox_resources').click(function () {
            selfRBE.app_helper.show_loader();
            var all_ids = [];
            if (this.checked) {
                $(".resources_selections").prop('checked', true);
            } else {
                $(".resources_selections").prop('checked', false);
            }

            $('.resources_selections').each(function () {
                var current_id = $(this).data('id').toString();
                if (typeof selfRBE.ids_session == 'undefined' || selfRBE.ids_session.length <= 0) {
                    selfRBE.ids_session = [];
                }
                all_ids.push(current_id);
                if (this.checked) {
                    var index = selfRBE.ids_session.indexOf(current_id);
                    if (index <= 0) {
                        selfRBE.ids_session.push(current_id);
                    }
                } else {
                    var index = selfRBE.ids_session.indexOf(current_id);
                    if (index > -1) {
                        selfRBE.ids_session.splice(index, 1);
                    }
                }
            });

            var data = {
                action: 'bulk_resource_list',
                ids: all_ids,
                type: 'collection_resource_files',
                bulk: 1
            };

            if (this.checked) {
                data.status = 'add';
            } else {
                data.status = 'remove';
            }
            selfRBE.app_helper.classAction($(this).data().url, data, 'JSON', 'GET', '', selfRBE, false);
        });
    };

    const binding_single_checkbox = function () {

        $(".resources_selections").unbind('change');
        $(".resources_selections").bind('change', function () {
            selfRBE.app_helper.show_loader();
            var data = {
                action: 'bulk_resource_list',
                type: 'collection_resource_files',
                bulk: 0
            };
            var current_id = $(this).data().id.toString();
            if (this.checked) {
                data.status = 'add';
                selfRBE.ids_session.push(current_id);
            } else {
                var index = selfRBE.ids_session.indexOf(current_id);
                if (index > -1) {
                    selfRBE.ids_session.splice(index, 1);
                }
                data.status = 'remove';
            }
            data.collection_resource_file_id = current_id;
            selfRBE.app_helper.classAction($(this).data().url, data, 'JSON', 'GET', '', selfRBE, false);
            $('.select_all_checkbox_resources').prop('checked', false);
        });
    };

    this.bulk_resource_list = function (response, container) {
        emptyCount();
        var ids = response[0]['ids'].split(',');
        if (ids != '' && ids.length > 0) {
            updateCount(ids.length);
        }
        selfRBE.app_helper.hide_loader();
    };


    this.set_checkbox_bulk = function () {
        emptyCount();
        if (selfRBE.ids_session != '' && selfRBE.ids_session.length > 0) {
            $.each(selfRBE.ids_session, function (index, value) {
                if ($(".resources_selections-" + value)) {
                    $(".resources_selections-" + value).prop('checked', true);
                }
            });
            updateCount(selfRBE.ids_session.length);
        }
    }
    ;

    const updateCount = function (number_selected) {
        emptyCount();
        if (number_selected > 0) {
            $('#collection_resource_datatable_filter label').append('<span style="color:#f05c1f" class="ml-10px font-weight-bold" id="resource_selected">  ( <strong  class="font-size-16px ">' + number_selected + '</strong> resource selected ) </span>  ');
            $('#collection_resource_datatable_filter label').append('<a href="javascript://" id="clear_all_selection">Clear selected</a>');
            $('#number_of_bulk_selected_popup').html('<span style="color:#f05c1f" class="ml-10px font-weight-bold" id="resource_selected">  ( <strong  class="font-size-16px ">' + number_selected + '</strong> resource(s) will be affected ) </span>');
        }
        $('#clear_all_selection').unbind('click');
        $('#clear_all_selection').bind('click', function () {
            var data = {
                action: 'bulk_resource_list_clear_all',
                ids: selfRBE.ids_session,
                bulk: 1,
                status: 'remove'
            };

            selfRBE.ids_session = [];
            updateCount(selfRBE.ids_session.length);

            selfRBE.app_helper.classAction($('.select_all_checkbox_resources').data().url, data, 'JSON', 'GET', '', selfRBE, false);
        });
    };

    this.update_progress = function (response) {
        $('#num_of_rec_updated').html(response[0].count);
        setTimeout(function () {
            get_progress_status();
        }, 5000);
    };

    this.actionBasedMethodExc = function (response, container, caller, requestData) {
        selfRBE.app_helper.actionBasedMethodExc(response, container, caller, requestData);
    };

    const emptyCount = function () {
        $('#resource_selected').remove();
        $('#number_of_bulk_selected_popup').html('');
        $('#clear_all_selection').remove();
    };
}

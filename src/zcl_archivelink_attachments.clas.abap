class ZCL_ARCHIVELINK_ATTACHMENTS definition
  public
  final
  create public .

    public section.

        types:
            ty_t_COMPONENTS type standard table of BAPICOMPON,
            ty_t_SIGNATURE type standard table of BAPISIGNAT,
            ty_t_CONNECTIONS type standard table of BAPICONNEC,
            ty_t_archivelink_attachment type standard table of zst_archivelink_attachment.

        class-methods:

            GET_STREAM
                importing
                    IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
                    iv_dpc type ref to /iwbep/if_mgw_conv_srv_runtime
                exporting
                    ER_STREAM type ref to DATA,

            get_attachments_for_object
                importing
                    iv_CLASSNAME type BAPIBDS01-CLASSNAME
                    iv_OBJECT_KEY type BAPIBDS01-OBJKEY
                exporting
                    et_attachments type ty_t_archivelink_attachment,

            get_attachment_info_for_object
                importing
                    iv_CLASSNAME type BAPIBDS01-CLASSNAME
                    iv_OBJECT_KEY type BAPIBDS01-OBJKEY
                exporting
                    et_COMPONENTS type ty_t_COMPONENTS
                    et_SIGNATURE type ty_t_SIGNATURE
                    et_CONNECTIONS type ty_t_CONNECTIONS,

            get_attachment
                importing
                    iv_CLASSNAME type BAPIBDS01-CLASSNAME
                    iv_OBJECT_KEY type BAPIBDS01-OBJKEY
                    iv_DOC_ID type BAPISIGNAT-doc_id
                exporting
                    ev_data type xstring
                    ev_mime_type type BAPICOMPON-mimetype
                    ev_comp_id type BAPICOMPON-comp_id.

    protected section.
    private section.
ENDCLASS.



CLASS ZCL_ARCHIVELINK_ATTACHMENTS IMPLEMENTATION.

    method get_attachments_for_object.

        zcl_archivelink_attachments=>get_attachment_info_for_object(
            exporting
                iv_classname = iv_classname
                iv_object_key = iv_object_key
            importing
                et_COMPONENTS = data(lt_COMPONENTS)
                et_SIGNATURE = data(lt_SIGNATURE)
                et_CONNECTIONS = data(lt_CONNECTIONS)
        ).

        sort lt_components by doc_count.

        data:
            lv_doc_id_anterior type BAPISIGNAT-doc_id.

        loop at lt_SIGNATURE assigning field-symbol(<ls_signature>).

            at first.
                data(lv_primeiro) = abap_true.
            endat.

            if lv_primeiro eq abap_true or <ls_signature>-doc_id ne lv_doc_id_anterior.

                read table lt_components
                with key doc_count = <ls_signature>-doc_count
                binary search
                assigning field-symbol(<ls_component>).

                append initial line to et_attachments assigning field-symbol(<ls_entityset>).

                <ls_entityset>-classname = iv_classname.
                <ls_entityset>-objkey = iv_object_key.
                <ls_entityset>-comp_id = <ls_component>-comp_id.
                <ls_entityset>-comp_size = <ls_component>-comp_size.
                <ls_entityset>-mimetype = <ls_component>-mimetype.

                <ls_entityset>-doc_id = <ls_signature>-doc_id.

                lv_doc_id_anterior = <ls_signature>-doc_id.

                lv_primeiro = abap_false.

            endif.

            case <ls_signature>-prop_name.

                when 'CREATED_AT'.

                    <ls_entityset>-created_at = <ls_signature>-prop_value.

                when 'CREATED_BY'.

                    <ls_entityset>-created_by = <ls_signature>-prop_value.

                when 'DESCRIPTION'.

                    <ls_entityset>-description = <ls_signature>-prop_value.

            endcase.


        endloop.

    endmethod.

    method get_attachment_info_for_object.

        call function 'BDS_BUSINESSDOCUMENT_GET_INFO'
          exporting
*            LOGICAL_SYSTEM      =
            CLASSNAME           = iv_classname
            CLASSTYPE           = 'BO'
*            CLIENT              = SY-MANDT
            OBJECT_KEY          = iv_object_key
*            ALL                 = 'X'
*            CHECK_STATE         = ' '              " BDS: Flag
          tables
            COMPONENTS          = et_COMPONENTS
            SIGNATURE           = et_SIGNATURE
            CONNECTIONS         = et_CONNECTIONS
*            EXTENDED_COMPONENTS =                  " SDOK: Component Attributes with Document ID
          exceptions
            NOTHING_FOUND       = 1
            PARAMETER_ERROR     = 2
            NOT_ALLOWED         = 3
            ERROR_KPRO          = 4
            INTERNAL_ERROR      = 5
            NOT_AUTHORIZED      = 6
            OTHERS              = 7
          .

        if sy-subrc <> 0.
*         message id sy-msgid type sy-msgty number sy-msgno
*           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

            return.

        endif.

    endmethod.

    method get_attachment.

        zcl_archivelink_attachments=>get_attachment_info_for_object(
            exporting
                iv_classname = iv_classname
                iv_object_key = iv_object_key
            importing
                et_COMPONENTS = data(lt_COMPONENTS)
                et_SIGNATURE = data(lt_SIGNATURE)
                et_CONNECTIONS = data(lt_CONNECTIONS)
        ).

        delete lt_SIGNATURE where doc_id ne iv_doc_id.

        read table lt_SIGNATURE
        index 1
        assigning field-symbol(<ls_SIGNATURE>).

        check sy-subrc eq 0.

        read table lt_COMPONENTS
        index <ls_signature>-doc_count
        assigning field-symbol(<ls_component>).

        check sy-subrc eq 0.

        ev_comp_id = <ls_component>-comp_id.

        read table lt_connections
        index <ls_signature>-doc_count
        assigning field-symbol(<ls_connection>).

        check sy-subrc eq 0.

        ev_mime_type = <ls_component>-mimetype.

        data:
            lt_INFOOBJECTS type standard table of BAPIINFOBJ.

        call function 'BDS_PHIOS_GET_RIGHT'
          exporting
*            LOGICAL_SYSTEM  =
            CLASSNAME       = iv_classname
            CLASSTYPE       = 'BO'
*            CLIENT          = SY-MANDT
            OBJECT_KEY      = iv_object_key
*            ALL             = 'X'
            CHECK_STATE     = 'X'
          tables
            INFOOBJECTS     = lt_INFOOBJECTS
            SIGNATURE       = lt_SIGNATURE
*            CONNECTIONS     =
          exceptions
            NOTHING_FOUND   = 1
            PARAMETER_ERROR = 2
            NOT_ALLOWED     = 3
            ERROR_KPRO      = 4
            INTERNAL_ERROR  = 5
            NOT_AUTHORIZED  = 6
            OTHERS          = 7
          .
        if sy-subrc <> 0.
*         message id sy-msgid type sy-msgty number sy-msgno
*           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            return.
        endif.

        read table lt_INFOOBJECTS
        index 1
        assigning field-symbol(<ls_INFOOBJECTS>).

        check sy-subrc eq 0.

        data:
            FILESIZE TYPE I,
            BINARY TYPE C,
            MIMETYPE(50) TYPE C,
            lt_DATA_TXT type standard table of SDOKCNTASC,
            lt_DATA_BIN type standard table of SDOKCNTBIN.


        call function 'SCMS_R3DB_GET'
          exporting
*            MANDT        = SY-MANDT
            CREP_ID      = 'BDS_DB'
            DOC_ID       = <ls_INFOOBJECTS>-ph_objid
*            PHIO_ID      =                  " Physical Document
            COMP_ID      = <ls_component>-comp_id
          importing
            COMP_SIZE    = FILESIZE
            BINARY_FLG   = BINARY
            MIMETYPE     = MIMETYPE
          tables
            DATA_TXT     = lt_DATA_TXT
            DATA_BIN     = lt_DATA_BIN
          exceptions
            ERROR_IMPORT = 1
            ERROR_CONFIG = 2
            OTHERS       = 3
          .
        if sy-subrc <> 0.
*         message id sy-msgid type sy-msgty number sy-msgno
*           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            return.
        endif.

      IF BINARY = SPACE.
*       convert text to binary
        CALL FUNCTION 'SCMS_TEXT_TO_BINARY'
          EXPORTING
*           FIRST_LINE            = 0
*           LAST_LINE             = 0
*           APPEND_TO_TABLE       = ' '
            MIMETYPE              = MIMETYPE
          IMPORTING
            OUTPUT_LENGTH         = FILESIZE
          TABLES
            TEXT_TAB              = lt_DATA_TXT
            BINARY_TAB            = lt_DATA_BIN
          EXCEPTIONS
            OTHERS                = 1
                  .
        IF SY-SUBRC ne 0.
*         transfer data

            return.

        ENDIF.
      ELSEIF BINARY = 'X'.
*       transfer data
*    ------   T -----------*

      ELSEIF BINARY = 'A'.
*       convert ftext to binary
        CALL FUNCTION 'SCMS_FTEXT_TO_BINARY'
          EXPORTING
            INPUT_LENGTH          = FILESIZE
*           FIRST_LINE            = 0
*           LAST_LINE             = 0
*           APPEND_TO_TABLE       = ' '
            MIMETYPE              = MIMETYPE
          IMPORTING
            OUTPUT_LENGTH         = FILESIZE
          TABLES
            FTEXT_TAB             = lt_DATA_TXT
            BINARY_TAB            = lt_DATA_BIN
          EXCEPTIONS
            OTHERS                = 1
                  .

        IF SY-SUBRC ne 0.
*         transfer data
*    ------   TIME STAMP PASSING -----------*
*    --- OPTIONAL PARAMETER ADDEDED FOR PHIO PROP TRANSFER---------*

            return.

        ENDIF.

      ELSE.

*        MESSAGE E068(CMS) WITH 'BINARY' BINARY SPACE SPACE INTO MSG.

        return.

      ENDIF.

        constants:
            c_max_length type i value 1022.

        data:
            lv_remaining type i.

        lv_remaining = filesize.

        loop at lt_DATA_BIN assigning field-symbol(<ls_data_bin>).

            data:
                lv_length type i.

            if lv_remaining < c_max_length.
                lv_length = lv_remaining.
            else.
                lv_length = c_max_length.
            endif.

            concatenate
                ev_data
                <ls_data_bin>-line(lv_length)
            into
                ev_data
            in byte mode.

            lv_remaining = lv_remaining - lv_length.

            if lv_remaining le 0.
                exit.
            endif.

        endloop.


    endmethod.

    method GET_STREAM.

        data:
            lv_CLASSNAME type BAPIBDS01-CLASSNAME,
            lv_OBJECT_KEY type BAPIBDS01-OBJKEY,
            lv_DOC_ID type BAPISIGNAT-doc_id.

        loop at it_key_tab assigning field-symbol(<ls_key>).

            case <ls_key>-name.

                when 'Classname'.
                    lv_classname = <ls_key>-value.

                when 'Objkey'.
                    lv_OBJECT_KEY = <ls_key>-value.

                when 'DocId'.
                    lv_DOC_ID = <ls_key>-value.

            endcase.

        endloop.

        TYPES:
            BEGIN OF TY_S_MEDIA_RESOURCE,
                MIME_TYPE TYPE STRING,
                VALUE TYPE XSTRING,
            END OF TY_S_MEDIA_RESOURCE.

        DATA:
             LS_STREAM TYPE TY_S_MEDIA_RESOURCE.

        zcl_archivelink_attachments=>get_attachment(
            exporting
                iv_classname = lv_classname
                iv_object_key = lv_object_key
                iv_doc_id = lv_doc_id
            importing
                ev_mime_type = data(lv_mime_type)
                ev_data = ls_stream-value
                ev_comp_id = data(lv_comp_id)
        ).

        ls_stream-mime_type = lv_mime_type.

        DATA:
              LS_LHEADER TYPE IHTTPNVP.

        LS_LHEADER-NAME = 'Content-Disposition'.

        LS_LHEADER-VALUE = |outline; filename="{ lv_comp_id }";|.

        iv_dpc->SET_HEADER( IS_HEADER = LS_LHEADER ).

        iv_dpc->COPY_DATA_TO_REF(
            EXPORTING
                IS_DATA = LS_STREAM
            CHANGING
                CR_DATA = ER_STREAM
        ).


    endmethod.

ENDCLASS.

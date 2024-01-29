class ZCL_Z_ARCHIVELINK_ATTA_DPC_EXT definition
  public
  inheriting from ZCL_Z_ARCHIVELINK_ATTA_DPC
  create public .

    public section.

        methods:

            /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM redefinition.

    protected section.

        methods:

            ARCHIVELINKOBJEC_GET_ENTITYSET redefinition,

            ARCHIVELINKATT01_GET_ENTITYSET redefinition.

    private section.
ENDCLASS.



CLASS ZCL_Z_ARCHIVELINK_ATTA_DPC_EXT IMPLEMENTATION.

    method ARCHIVELINKOBJEC_GET_ENTITYSET.

        " Implementado só para ter um exemplo quando a chave do entity set tem
        " '/' no conteúdo.

        append value #(
            CLASSNAME = '/CS46/CIM_MSGUROS'
            OBJKEY = '00000000000000000133BMJF2023'
        ) to ET_ENTITYSET.

    endmethod.

    method ARCHIVELINKATT01_GET_ENTITYSET.

        check IV_SOURCE_NAME eq 'ArchiveLinkObject'.

        data:
            lv_CLASSNAME type BAPIBDS01-CLASSNAME,
            lv_OBJECT_KEY type BAPIBDS01-OBJKEY.

        loop at it_key_tab assigning field-symbol(<ls_key>).

            case <ls_key>-name.

                when 'CLASSNAME'.
                    lv_classname = <ls_key>-value.

                when 'OBJKEY'.
                    lv_OBJECT_KEY = <ls_key>-value.

            endcase.

        endloop.

        zcl_archivelink_attachments=>get_attachments_for_object(
            exporting
                iv_classname = lv_classname
                iv_object_key = lv_object_key
            importing
                et_attachments = et_entityset
        ).

    endmethod.

    method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.

        zcl_archivelink_attachments=>GET_STREAM(
            exporting
                IT_KEY_TAB = IT_KEY_TAB
                iv_dpc = me
            importing
                ER_STREAM = ER_STREAM
        ).

    endmethod.

ENDCLASS.

class ZCL_Z_ARCHIVELINK_ATTA_MPC_EXT definition
  public
  inheriting from ZCL_Z_ARCHIVELINK_ATTA_MPC
  create public .

    public section.

        methods:
            DEFINE redefinition.

    protected section.
    private section.
ENDCLASS.



CLASS ZCL_Z_ARCHIVELINK_ATTA_MPC_EXT IMPLEMENTATION.

    method DEFINE.

        super->define( ).

        data(lv_entity_type) = model->get_entity_type( zcl_z_archivelink_atta_mpc_ext=>gc_archivelinkattachment ).
        data(lv_property) = lv_entity_type->get_property( 'Mimetype' ).
        lv_property->set_as_content_type( ).

    endmethod.

ENDCLASS.

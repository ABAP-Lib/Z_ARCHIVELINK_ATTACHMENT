# Z_ARCHIVELINK_ATTACHMENT
Archivelink: Serviço OData e utilitários de integração com serviços OData existentes

## Integration with Existant SEGW OData Service
- Create entity using structure ZST_ARCHIVELINK_ATTACHMENT.
- Set `Media` flag for the created entity.
- Edit Z*MPC_EXT ([example](https://github.com/ABAP-Lib/-CS46-CIM_APSEG/blob/main/src/z_cs46_cim_apseg/z_cs46_cim_apseg_anex/zcl_z_cs46_cim_apseg_a_mpc_ext.clas.abap)) and redefine `define` method to:
  - Call `set_as_content_type` for property `'Mimetype'` of the created entity.
  - Create corresponding assiciations.
- Edit Z*DPC_EXT ([example](https://github.com/ABAP-Lib/-CS46-CIM_APSEG/blob/main/src/z_cs46_cim_apseg/z_cs46_cim_apseg_anex/zcl_z_cs46_cim_apseg_a_dpc_ext.clas.abap)) and redefine:
  - `<new_entity>_get_entityset` method to call `zcl_archivelink_attachments=>get_attachments_for_object` method to retrieve attachments.
  - `/IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM` to call `zcl_archivelink_attachments=>GET_STREAM` method to retrieve attachment content.

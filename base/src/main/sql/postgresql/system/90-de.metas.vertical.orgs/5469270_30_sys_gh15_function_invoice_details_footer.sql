-- Function: de_metas_endcustomer_fresh_reports.docs_sales_orgs_invoice_details_footer(numeric, character varying)

-- DROP FUNCTION de_metas_endcustomer_fresh_reports.docs_sales_orgs_invoice_details_footer(numeric, character varying);

CREATE OR REPLACE FUNCTION de_metas_endcustomer_fresh_reports.docs_sales_orgs_invoice_details_footer(IN c_invoice_id numeric, IN ad_language character varying)
  RETURNS TABLE(documentnote text, p_cond text, p_term character varying, textcenter text) AS
$BODY$
SELECT
	dt.documentnote,
	replace(
		replace(
			replace(
				COALESCE( ptt.name_invoice, ptt.name, pt.name_invoice, pt.name ),
				'$datum_netto',
				to_char(i.dateinvoiced + pt.netdays, 'DD.MM.YYYY')
			),
			'$datum_skonto_1',
			to_char(i.dateinvoiced::date + pt.discountdays, 'DD.MM.YYYY')
		),
		'$datum_skonto_2',
		to_char(i.dateinvoiced::date + pt.discountdays2, 'DD.MM.YYYY')
	) AS P_Cond,
	COALESCE( reft.name, ref.name ) AS P_Term,
	CASE WHEN (i.descriptionbottom IS NOT NULL AND i.descriptionbottom != '')
			THEN '<br><br><br>'
			ELSE ''
		END || COALESCE(dtt.documentnote, dt.documentnote) 	as textcenter
FROM
	C_Invoice i
	LEFT OUTER JOIN C_PaymentTerm pt on i.C_PaymentTerm_ID = pt.C_PaymentTerm_ID AND pt.isActive = 'Y'
	LEFT OUTER JOIN C_PaymentTerm_Trl ptt on i.C_PaymentTerm_ID = ptt.C_PaymentTerm_ID AND ptt.AD_Language = $2 AND ptt.isActive = 'Y'
	LEFT OUTER JOIN AD_Ref_List ref ON i.PaymentRule = ref.Value AND ref.AD_Reference_ID = 195 AND ref.isActive = 'Y'
	LEFT OUTER JOIN AD_Ref_List_Trl reft ON reft.AD_Ref_List_ID = ref.AD_Ref_List_ID AND reft.AD_Language = $2 AND reft.isActive = 'Y'
	LEFT OUTER JOIN c_doctype dt ON i.c_doctype_id = dt.c_doctype_id AND dt.isActive = 'Y'
	LEFT OUTER JOIN c_doctype_trl dtt ON dt.c_doctype_id = dtt.c_doctype_id AND dtt.AD_Language = $2 AND dtt.isActive = 'Y'
	
WHERE
	i.C_Invoice_ID = $1 AND i.isActive = 'Y'

$BODY$
  LANGUAGE sql STABLE
  COST 100
  ROWS 1000;
ALTER FUNCTION de_metas_endcustomer_fresh_reports.docs_sales_orgs_invoice_details_footer(numeric, character varying)
  OWNER TO metasfresh;

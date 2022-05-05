USE[TOTVSBI11]
GO
CREATE VIEW [dbo].[Status_PV] AS
SELECT DISTINCT C5_NUM AS 'NUM_PV'
			,	C6_ITEM			AS	'ITEM'
			,	C6_PRODUTO		AS 'PRODUTO'
			,	B1_DESC			AS 'DESC_PRODUTO'
			,	B1_TIPO			AS 'TIPO_PRODUTO'
			,	C6_QTDVEN		AS 'QUANT_VENDA'
			,	CASE
					-- Formula para retornar a quantidade disponivel no estoque
					WHEN ((B2_QATU)-(B2_RESERVA+B2_QEMP+B2_QEMPSA) - B2_QACLASS) IS NOT NULL	THEN ((B2_QATU)-(B2_RESERVA+B2_QEMP+B2_QEMPSA) - B2_QACLASS)
					WHEN ((B2_QATU)-(B2_RESERVA+B2_QEMP+B2_QEMPSA) - B2_QACLASS) IS NULL		THEN '0'
				END AS 'SALDO_DISPONIVEL'
			,	C6_TES			AS 'TES'
			,	F4_TEXTO		AS 'DESC_TES'
			,	(SELECT TOP 1 NOME FROM PROTHEUS12_PRODUCAO.dbo.ZZUSUARIO WHERE CODUSUARIO = C5_VEND1) AS 'VENDEDOR'  -- SubSelect Para retornar o nome do vendedor
			,	C5_ZZNCLIE AS 'CLIENTE'
			,	USR_I.USR_NOME	AS 'CRIADOR_PV'
			,	CASE
					WHEN C9_BLEST	= '02'	THEN 'Bloqueado por estoque'
					WHEN C9_BLEST	= '03'	THEN 'Bloqueio Manual de Estoque'
					WHEN C9_BLEST	= ' '	THEN 'Pedido Liberado/Empenhado'
					WHEN C5_ZZTPBLQ = 'E' THEN 'Bloqueado por estoque'
					WHEN C5_LIBEROK <> '' AND C5_NOTA = '' AND C5_BLQ = '' THEN 'Pedido Liberado/Empenhado'
				END AS 'STATUS_PV'

FROM PROTHEUS12_PRODUCAO.dbo.SC5010 C5 WITH (NOLOCK) -- Tabela Cabeçalho do Pedido de Vendas

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SC6010 C6 WITH (NOLOCK) ON -- Tabela Itens do Pedido de Vendas
	C6_NUM		=	C5_NUM
AND C6_FILIAL	=	C5_FILIAL
AND C6.D_E_L_E_T_ = ''

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SB1010 B1 WITH (NOLOCK) ON -- Tabela de Produtos
	B1_COD = C6_PRODUTO
AND B1.D_E_L_E_T_ = ''

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SF4010 F4 WITH (NOLOCK) ON -- Tabela de TES
	F4_CODIGO	=	C6_TES
AND F4_FILIAL	=	C6_FILIAL
AND F4.D_E_L_E_T_ = ''

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SC9010 C9 WITH (NOLOCK) ON -- Tabela de Liberação do Pedido de Vendas
	C9_PEDIDO	=	C5_NUM
AND	C9_PRODUTO	=	C6_PRODUTO
AND	C9.D_E_L_E_T_ = ''

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SDC010 DC WITH (NOLOCK) ON -- Tabela de Composição de Empenhos
	DC_PRODUTO	=	C9_PRODUTO
AND DC_PEDIDO	=	C9_PEDIDO
AND DC.D_E_L_E_T_ = ''

LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SB2010 B2 WITH (NOLOCK) ON -- Tabela de Saldo no Estoque
	B2_COD		=	C9_PRODUTO
AND	B2_LOCAL	=	DC_LOCAL
AND B2_FILIAL	=	C9_FILIAL
AND B2.D_E_L_E_T_ = ''

-- Relacionamento para descriptografar o usuários LGI e LGA
LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SYS_USR USR_I ON (
        USR_I.USR_ID = (
            SUBSTRING(C5_USERLGI, 11, 1) +
            SUBSTRING(C5_USERLGI, 15, 1) +
            SUBSTRING(C5_USERLGI, 19, 1) +
            SUBSTRING(C5_USERLGI, 02, 1) +
            SUBSTRING(C5_USERLGI, 06, 1) +
            SUBSTRING(C5_USERLGI, 10, 1) +
            SUBSTRING(C5_USERLGI, 14, 1) +
            SUBSTRING(C5_USERLGI, 01, 1) +
            SUBSTRING(C5_USERLGI, 18, 1) +
            SUBSTRING(C5_USERLGI, 05, 1) +
            SUBSTRING(C5_USERLGI, 09, 1) +
            SUBSTRING(C5_USERLGI, 13, 1) +
            SUBSTRING(C5_USERLGI, 17, 1) +
            SUBSTRING(C5_USERLGI, 04, 1) +
            SUBSTRING(C5_USERLGI, 08, 1)
        )
    )
    LEFT JOIN PROTHEUS12_PRODUCAO.dbo.SYS_USR USR_A ON (
        USR_A.USR_ID = (
            SUBSTRING(C5_USERLGA, 11, 1) +
            SUBSTRING(C5_USERLGA, 15, 1) +
            SUBSTRING(C5_USERLGA, 19, 1) +
            SUBSTRING(C5_USERLGA, 02, 1) +
            SUBSTRING(C5_USERLGA, 06, 1) +
            SUBSTRING(C5_USERLGA, 10, 1) +
            SUBSTRING(C5_USERLGA, 14, 1) +
            SUBSTRING(C5_USERLGA, 01, 1) +
            SUBSTRING(C5_USERLGA, 18, 1) +
            SUBSTRING(C5_USERLGA, 05, 1) +
            SUBSTRING(C5_USERLGA, 09, 1) +
            SUBSTRING(C5_USERLGA, 13, 1) +
            SUBSTRING(C5_USERLGA, 17, 1) +
            SUBSTRING(C5_USERLGA, 04, 1) +
            SUBSTRING(C5_USERLGA, 08, 1)
        )
    )

-- Condições
WHERE
-- Apenas Pedidos de Vendas Liberados ou Bloqueados
((C5_LIBEROK <> '' AND C5_NOTA = '' AND C5_BLQ = '') OR (C5_ZZTPBLQ = 'E')) 

-- Apenas Produtos PC, PN e OL
AND B1_TIPO IN ('PC','PN','OL') 

GO



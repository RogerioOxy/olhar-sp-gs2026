import json
import math
import random
import sys
from pathlib import Path

SEMENTE = 20261119
MESES = 24
INICIO = (2024, 11)
AMOSTRA_VISTORIA = 0.10

DISTRITOS = [
    ("jardim-angela", "Jardim Ângela", "sul", "baixa", (290000, 330000)),
    ("grajau", "Grajaú", "sul", "baixa", (340000, 380000)),
    ("cidade-tiradentes", "Cidade Tiradentes", "leste", "baixa", (200000, 230000)),
    ("brasilandia", "Brasilândia", "norte", "baixa", (250000, 280000)),
    ("itaim-paulista", "Itaim Paulista", "leste", "baixa", (210000, 240000)),
    ("parelheiros", "Parelheiros", "sul", "baixa", (130000, 150000)),
    ("sapopemba", "Sapopemba", "leste", "media", (270000, 290000)),
    ("penha", "Penha", "leste", "media", (120000, 135000)),
    ("santana", "Santana", "norte", "media", (115000, 130000)),
    ("butanta", "Butantã", "oeste", "media", (50000, 60000)),
    ("ipiranga", "Ipiranga", "sul", "media", (100000, 115000)),
    ("moema", "Moema", "sul", "alta", (80000, 90000)),
    ("pinheiros", "Pinheiros", "oeste", "alta", (60000, 70000)),
    ("jardim-paulista", "Jardim Paulista", "oeste", "alta", (85000, 95000)),
    ("perdizes", "Perdizes", "oeste", "alta", (110000, 120000)),
    ("vila-mariana", "Vila Mariana", "sul", "alta", (130000, 140000)),
]

PROBLEMAS_POR_10MIL = {"baixa": 62.0, "media": 48.0, "alta": 36.0}
TAXA_REGISTRO = {"baixa": 0.38, "media": 0.58, "alta": 0.76}
TAXA_ATENDIMENTO = {"baixa": 0.61, "media": 0.73, "alta": 0.86}
SAZONAL = {1: 1.28, 2: 1.25, 3: 1.18, 4: 1.02, 5: 0.92, 6: 0.86,
           7: 0.84, 8: 0.86, 9: 0.92, 10: 1.00, 11: 1.08, 12: 1.22}

PICOS = {("grajau", 23): 1.55, ("penha", 23): 1.40}
QUEDAS_REGISTRO = {("cidade-tiradentes", 23): 0.6}


def poisson(rng, lam):
    if lam < 50:
        limite = math.exp(-lam)
        k, p = 0, 1.0
        while True:
            p *= rng.random()
            if p <= limite:
                return k
            k += 1
    return max(0, int(round(rng.gauss(lam, math.sqrt(lam)))))


def binomial(rng, n, p):
    if n < 60:
        return sum(1 for _ in range(n) if rng.random() < p)
    media = n * p
    return max(0, min(n, int(round(rng.gauss(media, math.sqrt(media * (1 - p)))))))


def meses():
    ano, mes = INICIO
    saida = []
    for _ in range(MESES):
        saida.append((ano, mes))
        mes += 1
        if mes > 12:
            mes, ano = 1, ano + 1
    return saida


def perfil_categorias(rng, faixa):
    base = {"buraco": 0.27, "iluminacao": 0.2, "poda": 0.18, "entulho": 0.17, "boca_de_lobo": 0.18}
    if faixa == "baixa":
        base["boca_de_lobo"] += 0.08
        base["entulho"] += 0.05
        base["poda"] -= 0.06
    elif faixa == "alta":
        base["poda"] += 0.08
        base["boca_de_lobo"] -= 0.06
    pesos = {c: max(0.03, v * rng.uniform(0.85, 1.15)) for c, v in base.items()}
    total = sum(pesos.values())
    return {c: round(v / total, 3) for c, v in pesos.items()}


def gerar():
    rng = random.Random(SEMENTE)
    lista_meses = meses()
    distritos = []
    for ident, nome, zona, faixa, (pmin, pmax) in DISTRITOS:
        populacao = rng.randrange(pmin, pmax, 1000)
        tendencia = rng.uniform(-0.004, 0.012)
        registrados, atendidos, vistoria = [], [], []
        for i, (_, mes) in enumerate(lista_meses):
            fator = SAZONAL[mes] * (1 + tendencia * i) * PICOS.get((ident, i), 1.0)
            problemas = poisson(rng, PROBLEMAS_POR_10MIL[faixa] * populacao / 10000 * fator)
            taxa_reg = min(0.95, TAXA_REGISTRO[faixa] * rng.uniform(0.92, 1.08))
            taxa_reg *= QUEDAS_REGISTRO.get((ident, i), 1.0)
            reg = binomial(rng, problemas, taxa_reg)
            ate = binomial(rng, reg, min(0.98, TAXA_ATENDIMENTO[faixa] * rng.uniform(0.94, 1.06)))
            achados = binomial(rng, problemas, AMOSTRA_VISTORIA)
            registrados.append(reg)
            atendidos.append(ate)
            vistoria.append(achados)
        distritos.append({
            "id": ident,
            "nome": nome,
            "zona": zona,
            "faixaRenda": faixa,
            "populacao": populacao,
            "categorias": perfil_categorias(rng, faixa),
            "registrados": registrados,
            "atendidos": atendidos,
            "achadosVistoria": vistoria,
        })
    return {
        "versao": 1,
        "sintetico": True,
        "semente": SEMENTE,
        "amostraVistoria": AMOSTRA_VISTORIA,
        "meses": [f"{a:04d}-{m:02d}" for a, m in lista_meses],
        "distritos": distritos,
    }


if __name__ == "__main__":
    padrao = Path(__file__).resolve().parent.parent / "assets" / "dados" / "territorio.json"
    destino = Path(sys.argv[1]) if len(sys.argv) > 1 else padrao
    destino.write_text(json.dumps(gerar(), ensure_ascii=False, indent=1), encoding="utf-8")

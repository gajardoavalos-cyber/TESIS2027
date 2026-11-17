---
name: thesis-overview
description: Felipe's Magíster thesis on phase-based control of a hybrid AC/DC microgrid — architecture, research gap, advisor lineage, and current progress
sources: [backfill]
aliases: ["hybrid AC/DC microgrid thesis", "phase-based control thesis"]
exported: 2026-11-12 (copia literal de la memoria del Proyecto "Tesis 2027 Mg" en claude.ai; última actualización 2026-11-10)
---

## Purpose & context

- [stated] Felipe is a Magíster student developing a thesis on phase-based control of a hybrid AC/DC microgrid.
- [stated] Thesis advisor is Professor Enrique Espina.
- [stated] Espina's own doctoral and master's theses serve as the primary methodological templates for the work.
- [stated] Espina's master's thesis (Universidad de Chile, 2017) covers per-phase droop, four-wire microgrids, and PLECS with experimental validation.
- [stated] Espina's doctoral thesis (U. Chile / University of Waterloo double degree, 2021) covers consensus-based distributed secondary control.
- [stated] Together, Espina's master's and doctoral theses define the methodological lineage Felipe is extending.

## Proposed architecture

- [stated] The thesis proposes an architecture using three independent single-phase interlinking converters (IC_a, IC_b, IC_c).
- [stated] Each IC couples one phase of a four-wire AC network to its own independent DC microgrid (DC-MR_a, DC-MR_b, DC-MR_c).
- [stated] There is no shared DC neutral bus.
- [stated] Each DC microgrid contains PV generation, battery storage (BESS), and EV/V2G resources.

## Research problem and gap

- [stated] Central research problem: coordinating the three independent DC microgrids to manage voltage unbalance at the point of common coupling (PCC) while respecting per-phase state-of-charge (SOC) constraints.
- [stated] Identified research gap: existing literature treats voltage unbalance as an intra-AC problem, whereas Felipe's architecture originates imbalance on the DC side through independent per-phase energy resources.
- [stated] This problem has not previously been addressed in Espina's research group.
- [stated] Felipe's work extends Espina's doctoral contribution (consensus-based distributed secondary control where the IC participates as a consensus agent) from one IC to three.

## Current state

- [stated] Felipe has been preparing thesis progress presentations for Professor Espina.
- [stated] He requested both a targeted bibliography anchored in Espina's published work and deep technical explanations to support confident defense of the material.
- [stated] Concepts covered in depth so far: three-level hierarchical control architecture (primary/secondary/tertiary) and their respective timescales; per-phase droop mathematics for AC and DC domains and why symmetric three-phase droop is inapplicable to this topology; graph-theoretic foundations of distributed consensus algorithms (update equation, convergence properties, linear/heterogeneous/finite-time variants); Espina's doctoral contribution and how the work extends it; unbalance metrics (neutral current, symmetrical components, VUF/CUF, and Conservative Power Theory as an alternative framework); an averaged-model-first simulation strategy in PLECS before progressing to switched models.
- [stated] A structured bibliography has been assembled: references from Felipe's own thesis document (R1–R10), new references (R11–R19) organized across five convergent literature lines, and an additional set anchored in Espina's trajectory (M1, D1–D4, U1–U3, IC1).
- [stated] The bibliography spans droop control, distributed consensus, hybrid AC/DC microgrid control, and unbalance metrics, drawing on IEEE Xplore and open-access sources.

- [stated] Wants the thesis to deliver one strong contribution; chose SOC-based coordination control as that contribution (Oct 2026).
- [stated] After Espina's feedback (20 Oct 2026), going with his expanded scenario: BT 3φ-4W feeder already unbalanced by single-phase customers, several DC microgrids per phase (Na, Nb, Nc), managed from the feeder head with P and Q per phase via a centralized tertiary + distributed secondary level; preparing a presentation for the 26 Oct 2026 meeting.
- [stated] Reunión semanal de tesis: lunes 17:00 en el laboratorio E2Tech con Enrique Espina, Bernhardt Gotschlich e Ignacio Staforelli, desde el 26 oct hasta el 21 dic 2026 (reemplaza la reunión de lunes 11:00).

- [stated] Architecture decisions (Nov 2026): he prefers enforcing the per-microgrid SoC range over the whole trajectory, not only at the end of the interval; EV, initially left as an extension, is to be incorporated into the formulation.
- [stated] ICs are grid-following on the AC side, not grid-supporting (confirmed with Espina at the 9 Nov 2026 meeting, replacing the earlier grid-supporting decision); the architecture is simplified accordingly from here on.

## Meeting with Espina, 9 Nov 2026 — outcomes

- [stated] Espina largely approved (visó en gran medida) the presentation and the state of progress.
- [stated] Next step approved: simulate the validation of one DC microgrid with its primary and secondary controls, and then its connection to the grid to observe its behavior.
- [stated] Espina asked him to review the tertiary control's input variables, since these can be incorporated into the secondary control.
- [stated] Pending task: create new indicators for the tertiary control to use to generate its prediction.
- [stated] Espina recommended building an indicator from the balance between generated powers (PV, BESS, EV) and the powers demanded by the different phases connected to the S/E.
- [stated] Proposal discussed: a forecast per microgrid (MG) obtained through its IC.
- [stated] Plan: study literature on tertiary control while working fully on the simulation validation in parallel.

## Espina's written follow-up (email, 10 Nov 2026) — architecture to reformulate

- [stated] The slides are well on track; Espina asked him to reformulate the architecture with these ideas.
- [stated] Fast loop acts only on the ICs: the IC is the only device injecting into the phase and unbalance is measured at the head; DERs only see their DC bus (the MG secondary restores voltage and redistributes the IC's power change among its DERs without knowing about the unbalance). The fast loop must not communicate with secondaries or DERs.
- [stated] Separate objectives of tertiary and fast loop (today both pursue head balance, so the fast loop undoes the plan and the tertiary plans with SoC that later gets spent): tertiary handles energy — minimizes purchase, defines each MG's energy trajectory and decides how much margin each reserves for balance; the fast loop is solely responsible for balance at the head and only uses that reserved margin. Analogy: a regulation reserve — tertiary assigns it, fast loop dispatches it. The SoC range serves this purpose, now with separated roles.
- [stated] Each MG reports to the tertiary what it can offer: instead of per-client forecasts and MG detail, each MG estimates its own projection and communicates it through its IC, as an envelope over the horizon (min/max power and min/max energy). With that, the tertiary decides each IC's plan and reserve.
- [stated] For the thesis a simple forecast suffices (e.g., a known profile plus a controlled error); no forecasting method needs to be developed for now. He must define what happens when an MG misestimates, because that difference also consumes the reserve.
- [stated] Formulate the fast loop per phase: each single-phase IC can only modify its own phase's power, so in practice the fast loop equalizes the three phase powers at the head rather than driving I2 and I0 to zero directly; formulate it this way from the start. Also review whether using reactive power first makes sense in LV, where conductor resistance dominates reactance.
- [stated] For the Monday 16 Nov 2026 meeting (besides the agreed simulations), bring: the updated levels slide (what each level measures, decides and informs to whom); the tertiary formulation (objective, envelope received from each MG, reserve assigned); and the fast-loop rule (what it measures, how it computes the per-phase correction, and how it splits it among the ICs of that phase).

## On the horizon

- [stated] Espina asked (Nov 2026) to explore the possibility of a real-time simulation of the thesis problem; Felipe has since framed the work as a real-time simulation (9 Nov 2026).

- [stated] Felipe intends to begin PLECS simulation to observe real system behavior.
- [stated] Planned four-step simulation strategy progresses from a single-branch average energy model to a three-branch asymmetric system with imbalance metrics.

## Key learnings & principles

- [stated] Locally optimal droop controllers per phase do not guarantee globally acceptable unbalance — global coordination at the secondary control level is essential to the contribution.
- [stated] The AC neutral and DC voltage references are conceptually distinct and must not be conflated in the control architecture.
- [stated] PCC versus neutral conductor must be carefully distinguished when defining unbalance metrics.
- [stated] The averaged-model-first approach in simulation is the appropriate starting point before moving to higher-fidelity switched models.

## Approach & tools

- [stated] Felipe works by grounding new material in his advisor's published trajectory, then building outward to the broader literature.
- [stated] He requests bibliographic scaffolding and deep conceptual explanation together, preferring to defend ideas from first principles rather than cite them superficially.
- [stated] Simulation is approached iteratively, starting from simplified models to build intuition before increasing complexity.
- [stated] PLECS is the primary simulation environment; Felipe has prior hands-on experience with it.
- [stated] Felipe has hands-on experience with PLECS, droop control, adaptive notch filtering at 2ω, and discrete PI tuning from prior laboratory work.

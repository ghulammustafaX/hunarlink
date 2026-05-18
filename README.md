# 🔗 HunarLink

> **Book any home service in seconds**

This project is an Agentic AI System designed to automate the end-to-end lifecycle of informal service requests (plumbers, AC technicians, IT support). Operating under a "One App, Two Worlds" architecture, the system provides a sleek user interface for clients while utilizing a Google Antigravity-powered agent to handle intent parsing, real-world discovery via Google Maps, and simulated booking execution.


---

## Stack
| Layer | Tech |
|-------|------|
| Orchestration | Google Antigravity |
| Mobile | Flutter |
| Data | Google Maps Places API |
| Simulation | Firebase Firestore |
| AI/NLP | Gemini via Antigravity |

# HunarLink — Agent Prompts

## Active Prompts (sent to Gemini API)
- `intent_agent.txt` — Multilingual NLP parser

## Reference Prompts (architecture documentation for judges)
- `ranking_agent.txt` — Documents the scoring formula used in rank_and_select.js
- `booking_agent.txt` — Documents the Firebase booking payload written by execute_booking.js

The fetch_maps_data and schedule_followup agents operate via
direct API calls and JavaScript logic — no LLM prompt needed.

## Flow

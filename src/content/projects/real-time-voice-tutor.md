---
title: 大小模型协同驱动的实时语音伴学系统
slug: real-time-voice-tutor
summary: 面向 K12 智能伴学场景，构建覆盖语音感知、任务理解、模型路由、知识讲解和语音反馈的实时交互系统，通过大小模型协同、流式推理和异步后台任务降低用户感知延迟。
featured: false
visible: true
order: 4
categories: [Multi-Agent, Speech AI]
tags: [实时语音, 模型路由, 智能伴学]
stack: [FastAPI, WebSocket, VAD, ASR, TTS, Qwen, LoRA, Multi-Agent, Redis]
highlights:
  - 整合 VAD、ASR、TTS 和 WebSocket
  - 支持语音输入、流式生成、语音播报和实时打断
  - 将轻量任务路由至小模型或规则模块
  - 将复杂知识讲解与多轮推理交由大模型
  - 将实时链路和画像更新、质量评估、摘要与长期记忆任务分离
  - 使用 LoRA 对 Qwen 系列模型进行教育场景定向微调
  - 使用流式推理和分句 TTS 提升首响速度
---

## 实时交互

系统整合 VAD、ASR、TTS 与 WebSocket，支持语音输入、流式生成、语音播报和实时打断。

## 大小模型协同

轻量任务交由小模型或规则模块处理，复杂知识讲解与多轮推理交由大模型；实时交互链路与画像更新、质量评估、摘要和长期记忆等异步任务相互分离。

## 场景适配

使用 LoRA 对 Qwen 系列模型进行教育场景定向微调，并通过流式推理和分句 TTS 提升首响速度。

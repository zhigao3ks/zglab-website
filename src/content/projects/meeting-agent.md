---
title: 实时会议理解与智能纪要 Agent
slug: meeting-agent
summary: 面向企业会议场景，构建覆盖浏览器录音、实时语音转写、任务状态管理、会议摘要、待办提取和最终结果存储的智能会议系统。
status: building
featured: false
visible: true
order: 2
categories: [Agent, Real-time AI]
tags: [会议理解, 实时转写, 状态机]
stack: [Vue, Spring Boot, MySQL, WebSocket, Docker, Nginx, 通义听悟]
highlights:
  - 浏览器录音和实时音频推流
  - 实时转写和临时结果展示
  - 会议任务状态机
  - 幂等结束机制
  - 会议摘要、待办、逐字稿和纪要生成
  - 异常中断、任务日志和结果持久化
---

## 目标

将会议从实时音频输入到结构化纪要输出串联为可恢复、可追踪的任务流程。

## 实时链路

浏览器负责录音和实时音频推流，系统通过 WebSocket 展示临时转写结果，并围绕任务状态机管理会议的创建、进行、结束和异常状态。

## 结果管理

系统生成会议摘要、待办、逐字稿和纪要，并通过幂等结束机制、任务日志和结果持久化处理重复请求与异常中断。

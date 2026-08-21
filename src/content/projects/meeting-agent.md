---
title: 实时会议理解与智能纪要 Agent
slug: meeting-agent
summary: 面向真实会议场景构建的实时 AI 应用，覆盖音频采集、语音转写、状态管理、摘要生成和结构化纪要输出。
status: building
featured: false
visible: true
order: 4
categories: [Agent, Real-time AI]
tags: [语音交互, 会议理解, WebSocket, 状态机]
stack: [Vue, Spring Boot, MySQL, WebSocket, Docker, Nginx, 通义听悟]
highlights:
  - 实现浏览器端音频采集和实时语音处理链路。
  - 设计会议任务状态机管理创建、录音、结束和异常恢复流程。
  - 支持逐字稿、会议摘要和待办事项生成。
  - 通过任务日志和幂等机制提升系统可靠性。
---

## 项目目标

探索大模型能力在企业实时协作场景中的落地方式，将非结构化会议内容转化为可执行的信息资产。

## 系统链路

系统连接浏览器音频采集、实时转写服务、后端任务管理和 AI 总结流程，形成从语音输入到结构化输出的完整闭环。

## 工程实践

重点解决实时通信、任务状态管理、异常恢复和结果持久化等 AI 应用工程问题。

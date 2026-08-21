---
title: ZGLab Personal Knowledge Assistant
slug: zglab-rag
summary: 面向个人知识管理场景构建的生产级 RAG 助手系统，实现知识获取、检索优化、证据溯源和智能问答闭环。
status: production
featured: true
visible: true
order: 1
categories: [RAG, LLM, AI Application]
tags: [知识库, Embedding, Retrieval, Evaluation]
stack:
  [
    Python,
    FastAPI,
    SQLite,
    BGE-Embedding,
    Vue,
    Nginx,
    Systemd,
  ]
highlights:
  - 构建 Markdown 知识导入与结构感知切分 Pipeline。
  - 完成 Embedding 模型评测与检索效果分析。
  - 实现来源引用和证据不足状态反馈。
  - 完成公网部署并提供 AI 问答服务。
---

## 项目目标

构建一个属于个人知识体系的 AI 助手，让分散的项目文档、技术笔记和工程经验能够被自然语言检索和调用。

## 核心能力

系统覆盖知识采集、Chunk 管理、Embedding 检索、答案生成和来源展示完整链路。

## 工程实践

重点关注 RAG 系统中的检索质量、答案可信度和生产部署能力。

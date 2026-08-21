---
title: ZGLab Personal Knowledge Agent
slug: zglab-rag
summary: 面向个人知识体系构建的 AI Agent 平台，目前以 RAG 能力为核心阶段，持续演进为具备知识理解、主动检索、工具调用和长期记忆能力的个人智能助手。
status: online
featured: true
visible: true
order: 1
categories: [Agent, RAG, LLM, AI Application]
tags: [知识库, Agent, Retrieval, Memory, Evaluation]
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
  - 构建 Markdown 知识导入、结构感知切分和索引 Pipeline，为 Agent 提供可靠知识基础。
  - 完成 Embedding 模型评测与检索效果分析，持续优化知识召回质量。
  - 实现来源引用、证据反馈和可解释回答机制，提升 AI 输出可信度。
  - 完成公网部署，形成可持续演进的个人 AI 助手基础设施。
---

## 项目目标

构建一个属于个人知识体系的 AI Agent，让分散的项目文档、技术笔记和工程经验能够被理解、检索和调用。

当前阶段聚焦于 Agent 的知识增强能力，通过 RAG Pipeline 建立稳定的知识获取与检索基础，并为后续引入任务规划、工具调用、长期记忆和主动协作能力做准备。

## 当前能力

系统已经覆盖知识采集、结构化 Chunk 管理、Embedding 检索、答案生成和来源展示完整链路。

后续将持续演进为具备个人上下文理解、知识管理和任务执行能力的长期智能助手。

## 工程实践

项目重点探索 AI Agent 系统中的知识增强、检索质量、可信回答和生产化部署问题，并通过真实运行环境持续验证系统能力。
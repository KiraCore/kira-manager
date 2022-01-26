import logging

def main():
    logging.basicConfig(filename='update.log', level=logging.DEBUG,encoding="utf-8", force=True)
    logger = logging.getLogger(__name__)

if __name__ == "__main__":
    main()